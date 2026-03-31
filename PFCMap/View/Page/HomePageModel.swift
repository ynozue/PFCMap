import SwiftUI
import MapKit
import Observation

@MainActor
@Observable
final class HomePageModel {
    var cameraPosition: MapCameraPosition = .automatic
    var isLoading = false
    var errorMessage: String?
    var visibleRegion: MKCoordinateRegion?
    var isMenuShowing = false
    
    init() {}
    
    func onAppear(locationStore: LocationStore) {
        // スプラッシュですでに取得済みの現在地をカメラ位置に設定
        if let location = locationStore.currentLocation {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    func onShopSelectionChange(shopIds: Set<UUID>, shopCatalogStore: ShopCatalogStore, shopSearchStore: ShopSearchStore) async {
        let selectedShops = shopCatalogStore.shops.filter { shopIds.contains($0.id) }
        let queries = selectedShops.map { $0.name }
        
        if queries.isEmpty {
            shopSearchStore.clear()
            return
        }
        
        do {
            try await shopSearchStore.search(queries: queries, region: visibleRegion)
        } catch {
            print("Search failed: \(error)")
        }
    }
}
