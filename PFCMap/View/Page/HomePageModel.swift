import SwiftUI
import MapKit
import Observation
import NZData

enum ActiveMapApp: String, Sendable, Identifiable {
    case apple = "Apple マップ"
    case google = "Google マップ"
    
    var id: String { self.rawValue }
}

@MainActor
@Observable
final class HomePageModel {
    var cameraPosition: MapCameraPosition = .automatic
    var isLoading = false
    var errorMessage: String?
    var visibleRegion: MKCoordinateRegion?
    var isMenuShowing = false
    var selectedResultID: UUID? = nil
    var searchResults: [ShopSearchResult] = []
    var loadingMessage: String = ""
    
    // Route variables
    var selectedRoute: MKRoute? = nil
    var selectedRouteDuration: TimeInterval? = nil
    var selectedRouteDistance: CLLocationDistance? = nil
    var isCalculatingRoute = false
    
    // Map launching state
    var showMapAppAlert = false
    var selectedMapApp: ActiveMapApp? = nil
    var showLocationPermissionAlert = false

    var currentLocation: Location? = nil

    let store: Store
    private let locationRepository: any LocationRepository
    private let shopSearchRepository: any ShopSearchRepository
    private let analyticsService: any AnalyticsService

    init(
        store: Store,
        locationRepository: any LocationRepository,
        shopSearchRepository: any ShopSearchRepository,
        analyticsService: any AnalyticsService
    ) {
        self.store = store
        self.locationRepository = locationRepository
        self.shopSearchRepository = shopSearchRepository
        self.analyticsService = analyticsService
    }

    func onAppear() {
        isLoading = true
        Task {
            defer {
                isLoading = false
                loadingMessage = ""
            }
            do {
                // 1. 設定フェッチ、現在地取得、店舗リスト取得を並行実行
                self.loadingMessage = "初期データを読み込んでいます..."

                async let fetchSettingsTask: () = store.loadSettings()
                async let requestLocationTask = locationRepository.requestLocation()
                async let fetchShopsTask: () = store.refreshShops()

                // 並行処理の完了を待つ (SettingsとShops)
                await fetchSettingsTask
                try await fetchShopsTask

                // 位置情報の取得を待つ (エラーハンドリングはMainActor上で行う)
                do {
                    let location = try await requestLocationTask
                    self.currentLocation = location
                } catch {
                    print("Location request failed: \(error)")
                    // 位置情報が取得できない場合、東京駅をデフォルトとしてセットしアラートを表示
                    self.currentLocation = .tokyoStation
                    self.showLocationPermissionAlert = true
                }

                // Camera の位置を更新
                updateCameraPosition(distance: store.mapDistance.rawValue)

                // 2. 取得した情報をもとに地図上の店舗情報を検索
                self.loadingMessage = "地図上の店舗情報を検索しています..."
                await executeSearch()

            } catch {
                print("Initial data acquisition failed: \(error)")
                errorMessage = "情報の取得に失敗しました。\(error.localizedDescription)"
            }
        }
    }

    func onDismissMenu() {
        Task {
            do {
                await store.loadSettings()
                try await store.refreshShops()
                await executeSearch()
            } catch {
                print("Failed to reload after menu dismiss: \(error)")
                errorMessage = "情報の取得に失敗しました。\(error.localizedDescription)"
            }
        }
    }

    /// バックグラウンド同期などで Store の shops が更新された際に検索結果を追従させる
    func onShopsUpdated() {
        Task {
            await executeSearch()
        }
    }

    private func executeSearch() async {
        let disabledIds = store.disabledShopIds
        let shopsData = store.shops
        let queries = await Task.detached {
            shopsData
                .filter { shop in
                    !disabledIds.contains(shop.id) &&
                    shop.items.contains(where: { $0.type == ShopItem.stapleFoodType })
                }
                .map { $0.name }
        }.value

        if !queries.isEmpty {
            let radiusWithBuffer = Double(store.mapDistance.rawValue) + 100.0

            let searchCenter = currentLocation?.coordinate ?? Location.tokyoStation.coordinate
            let region = visibleRegion ?? MKCoordinateRegion(center: searchCenter, latitudinalMeters: radiusWithBuffer * 2, longitudinalMeters: radiusWithBuffer * 2)

            do {
                let results = try await shopSearchRepository.search(queries: queries, region: region)
                self.searchResults = results
                logSearch()
            } catch {
                print("Search error: \(error)")
            }
        } else {
            self.searchResults = []
        }
    }
    
    func updateCameraPosition(distance: Int) {
        guard let location = self.currentLocation else { return }
        let distanceDouble = Double(distance)
        let diameter = (distanceDouble + 100) * 2
        
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: diameter,
                longitudinalMeters: diameter
            ))
        }
    }
    
    func openInMaps(result: ShopSearchResult) {
        let location = CLLocation(
            latitude: result.location.latitude,
            longitude: result.location.longitude
        )
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = result.name
        
        // 徒歩での経路案内をデフォルトに設定
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
    
    func canOpenAppleMaps() -> Bool {
        guard let url = URL(string: "maps://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func canOpenGoogleMaps() -> Bool {
        guard let url = URL(string: "comgooglemaps://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func openAppStoreForGoogleMaps() {
        if let url = URL(string: "https://apps.apple.com/app/google-maps/id585027354") {
            UIApplication.shared.open(url)
        }
    }
    
    func openInGoogleMaps(result: ShopSearchResult) {
        let latitude = result.location.latitude
        let longitude = result.location.longitude
        // 徒歩経路をデフォルトに設定（directionsmode=walking）
        let urlString = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=walking"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func updateMapDistance(distance: MapDistance) {
        Task {
            await store.updateMapDistance(distance)
            await executeSearch()
            updateCameraPosition(distance: distance.rawValue)
        }
    }

    func updateProteinThreshold(threshold: ProteinThreshold) {
        Task {
            await store.updateProteinThreshold(threshold)
            logSearch()
        }
    }

    func updateFatThreshold(threshold: FatThreshold) {
        Task {
            await store.updateFatThreshold(threshold)
            logSearch()
        }
    }

    func logSearch() {
        analyticsService.logSearch(
            proteinThreshold: store.proteinThreshold.rawValue,
            fatThreshold: store.fatThreshold.rawValue,
            mapDistance: store.mapDistance.rawValue
        )
    }
    
    func logViewShopDetail(shopName: String) {
        analyticsService.logViewShopDetail(shopName: shopName)
    }
    
    func calculateRouteToSelectedResult() {
        guard let currentLocation else {
            self.selectedRoute = nil
            return
        }
        guard let selectedResultID,
              let destinationResult = searchResults.first(where: { $0.id == selectedResultID }) else {
            self.selectedRoute = nil
            self.selectedRouteDuration = nil
            self.selectedRouteDistance = nil
            return
        }
        
        isCalculatingRoute = true
        
        let start = currentLocation.coordinate
        let end = CLLocationCoordinate2D(
            latitude: destinationResult.location.latitude,
            longitude: destinationResult.location.longitude
        )
        
        Task {
            let request = MKDirections.Request()
            request.source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
            request.destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            do {
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    self.selectedRoute = route
                    self.selectedRouteDuration = route.expectedTravelTime
                    self.selectedRouteDistance = route.distance
                    
                    updateCameraPositionToFitRoute(route: route)
                }
            } catch {
                print("Failed to calculate route: \(error)")
                self.selectedRoute = nil
                self.selectedRouteDuration = nil
                self.selectedRouteDistance = nil
            }
            isCalculatingRoute = false
        }
    }
    
    private func updateCameraPositionToFitRoute(route: MKRoute) {
        let rect = route.polyline.boundingMapRect
        var region = MKCoordinateRegion(rect)
        
        // 全体が綺麗に収まるように1.4倍に拡大
        region.span.latitudeDelta *= 1.4
        region.span.longitudeDelta *= 1.4
        
        // 下部の詳細カードと重ならないように、中心を少し南（緯度を下げる）にシフトして
        // 経路全体を画面上部に寄せる
        region.center.latitude -= region.span.latitudeDelta * 0.15
        
        withAnimation {
            cameraPosition = MapCameraPosition.region(region)
        }
    }
    
    func distanceString(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000.0)
        }
    }
    
    func triggerMapAppAlert(app: ActiveMapApp) {
        self.selectedMapApp = app
        self.showMapAppAlert = true
    }
    
    var routeMidCoordinate: CLLocationCoordinate2D? {
        guard let route = selectedRoute else { return nil }
        let pointCount = route.polyline.pointCount
        guard pointCount > 0 else { return nil }
        let midIndex = pointCount / 2
        let midPoint = route.polyline.points()[midIndex]
        return midPoint.coordinate
    }
}
