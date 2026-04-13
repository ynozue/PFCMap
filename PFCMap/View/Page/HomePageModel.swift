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
    
    // Shared Data normally held by Store
    var currentLocation: Location? = nil
    var shops: [ShopCatalog] = []
    var mapDistance: MapDistance = .m500
    var proteinThreshold: ProteinThreshold = .g20
    var fatThreshold: FatThreshold = .g20
    var disabledShopIds: Set<UUID> = []
    
    init() {}
    func onAppear(factory: Factory) {
        isLoading = true
        Task {
            defer { 
                isLoading = false 
                loadingMessage = ""
            }
            do {
                // Settings
                await fetchSettings(factory: factory)
                
                // 1. 現在地情報の取得
                self.loadingMessage = "現在地情報を取得しています..."
                let locationRepository = factory.makeLocationRepository()
                let location = try await locationRepository.requestLocation()
                self.currentLocation = location
                
                // Camera
                updateCameraPosition(distance: self.mapDistance.rawValue)
                
                // 2. 表示対象のShopリスト一覧の取得
                self.loadingMessage = "店舗リスト一覧を取得しています..."
                let shopCatalogRepository = factory.makeShopCatalogRepository()
                self.shops = try await shopCatalogRepository.fetchShops()
                
                // 3. Shopリストから地図上の店舗情報を検索
                self.loadingMessage = "地図上の店舗情報を検索しています..."
                await executeSearch(factory: factory)
                
                // 4. 検索にヒットした店舗情報のメニューを表示
                self.loadingMessage = "メニューを表示しています..."
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                print("Initial data acquisition failed: \(error)")
                errorMessage = "情報の取得に失敗しました。\(error.localizedDescription)"
            }
        }
    }
    
    func onDismissMenu(factory: Factory) {
        Task {
            await fetchSettings(factory: factory)
            let shopCatalogRepository = factory.makeShopCatalogRepository()
            self.shops = try await shopCatalogRepository.fetchShops()
            await executeSearch(factory: factory)
        }
    }
    
    private func fetchSettings(factory: Factory) async {
        let userDefaultsService = factory.makeUserDefaultsService()
        
        let distance: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.mapDistance)
        self.mapDistance = MapDistance(rawValue: distance) ?? .m500

        let protein: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.proteinThreshold)
        self.proteinThreshold = ProteinThreshold(rawValue: protein) ?? .g20
        
        let fat: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.fatThreshold)
        self.fatThreshold = FatThreshold(rawValue: fat) ?? .g20

        let ids: [String] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        self.disabledShopIds = Set(ids.compactMap { UUID(uuidString: $0) })
    }

    private func executeSearch(factory: Factory) async {
        let queries = self.shops
            .filter { !self.disabledShopIds.contains($0.id) }
            .map { $0.name }
        
        if !queries.isEmpty {
            let radiusWithBuffer = Double(self.mapDistance.rawValue) + 100.0
            
            let searchCenter = currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125) // fallback to Tokyo
            let region = visibleRegion ?? MKCoordinateRegion(center: searchCenter, latitudinalMeters: radiusWithBuffer * 2, longitudinalMeters: radiusWithBuffer * 2)
            
            let shopSearchRepository = factory.makeShopSearchRepository()
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
    
    func updateMapDistance(distance: MapDistance, factory: Factory) {
        self.mapDistance = distance
        let service = factory.makeUserDefaultsService()
        Task {
            await service.save(key: PFCMapUserDefaultsKeys.mapDistance, value: distance.rawValue)
            await executeSearch(factory: factory)
            updateCameraPosition(distance: distance.rawValue)
        }
    }
    
    func updateProteinThreshold(threshold: ProteinThreshold, factory: Factory) {
        self.proteinThreshold = threshold
        let service = factory.makeUserDefaultsService()
        Task { await service.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: threshold.rawValue) }
    }
    
    func updateFatThreshold(threshold: FatThreshold, factory: Factory) {
        self.fatThreshold = threshold
        let service = factory.makeUserDefaultsService()
        Task { await service.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: threshold.rawValue) }
    }
}
