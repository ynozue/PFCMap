import SwiftUI
import MapKit
import Observation
import NZData

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
    var showLocationPermissionAlert = false
    
    // Shared Data normally held by Store
    var currentLocation: Location? = nil
    var shops: [ShopCatalog] = []
    var mapDistance: MapDistance = .m500
    var proteinThreshold: ProteinThreshold = .g20
    var fatThreshold: FatThreshold = .g20
    var disabledShopIds: Set<UUID> = []
    
    private let locationRepository: any LocationRepository
    private let shopCatalogRepository: any ShopCatalogRepository
    private let shopSearchRepository: any ShopSearchRepository
    private let userDefaultsService: any UserDefaultsService
    
    init(
        locationRepository: any LocationRepository,
        shopCatalogRepository: any ShopCatalogRepository,
        shopSearchRepository: any ShopSearchRepository,
        userDefaultsService: any UserDefaultsService
    ) {
        self.locationRepository = locationRepository
        self.shopCatalogRepository = shopCatalogRepository
        self.shopSearchRepository = shopSearchRepository
        self.userDefaultsService = userDefaultsService
    }
    
    func onAppear() {
        isLoading = true
        Task {
            defer { 
                isLoading = false 
                loadingMessage = ""
            }
            do {
                // Settings
                await fetchSettings()
                
                // 1. 現在地情報の取得
                self.loadingMessage = "現在地情報を取得しています..."
                do {
                    let location = try await locationRepository.requestLocation()
                    self.currentLocation = location
                } catch {
                    print("Location request failed: \(error)")
                    // 位置情報が取得できない場合、東京駅をセット
                    self.currentLocation = Location(latitude: 35.681236, longitude: 139.767125)
                    self.showLocationPermissionAlert = true
                }
                
                // Camera
                updateCameraPosition(distance: self.mapDistance.rawValue)
                
                // 2. 表示対象のShopリスト一覧の取得
                self.loadingMessage = "店舗リスト一覧を取得しています..."
                self.shops = try await shopCatalogRepository.fetchShops()
                
                // 3. Shopリストから地図上の店舗情報を検索
                self.loadingMessage = "地図上の店舗情報を検索しています..."
                await executeSearch()
                
                // 4. 検索にヒットした店舗情報のメニューを表示
                self.loadingMessage = "メニューを表示しています..."
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                print("Initial data acquisition failed: \(error)")
                errorMessage = "情報の取得に失敗しました。\(error.localizedDescription)"
            }
        }
    }
    
    func onDismissMenu() {
        Task {
            await fetchSettings()
            self.shops = try await shopCatalogRepository.fetchShops()
            await executeSearch()
        }
    }
    
    private func fetchSettings() async {
        let distance: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.mapDistance)
        self.mapDistance = MapDistance(rawValue: distance) ?? .m500

        let protein: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.proteinThreshold)
        self.proteinThreshold = ProteinThreshold(rawValue: protein) ?? .g20
        
        let fat: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.fatThreshold)
        self.fatThreshold = FatThreshold(rawValue: fat) ?? .g20

        let ids: [String] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        self.disabledShopIds = Set(ids.compactMap { UUID(uuidString: $0) })
    }

    private func executeSearch() async {
        let disabledIds = self.disabledShopIds
        let shopsData = self.shops
        let queries = await Task.detached {
            shopsData
                .filter { shop in
                    !disabledIds.contains(shop.id) &&
                    shop.items.contains(where: { $0.type == "主食" })
                }
                .map { $0.name }
        }.value
        
        if !queries.isEmpty {
            let radiusWithBuffer = Double(self.mapDistance.rawValue) + 100.0
            
            let searchCenter = currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125) // fallback to Tokyo
            let region = visibleRegion ?? MKCoordinateRegion(center: searchCenter, latitudinalMeters: radiusWithBuffer * 2, longitudinalMeters: radiusWithBuffer * 2)
            
            do {
                let results = try await shopSearchRepository.search(queries: queries, region: region)
                self.searchResults = results
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
        self.mapDistance = distance
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.mapDistance, value: distance.rawValue)
            await executeSearch()
            updateCameraPosition(distance: distance.rawValue)
        }
    }
    
    func updateProteinThreshold(threshold: ProteinThreshold) {
        self.proteinThreshold = threshold
        Task { await userDefaultsService.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: threshold.rawValue) }
    }
    
    func updateFatThreshold(threshold: FatThreshold) {
        self.fatThreshold = threshold
        Task { await userDefaultsService.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: threshold.rawValue) }
    }
}
