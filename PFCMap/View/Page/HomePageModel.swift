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
    
    func onAppear(locationStore: LocationStore, shopCatalogStore: ShopCatalogStore, shopSearchStore: ShopSearchStore) {
        // スプラッシュですでに取得済みの現在地をカメラ位置に設定
        if let location = locationStore.currentLocation {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 1200, // 半径500m + 100m = 600m (直径1200m)
                longitudinalMeters: 1200
            ))
        }
        
        // 全ショップを地図上に検索して表示
        Task {
            let queries = shopCatalogStore.shops.map { $0.name }
            if !queries.isEmpty {
                do {
                    try await shopSearchStore.search(queries: queries, region: visibleRegion)
                } catch {
                    print("Initial search failed: \(error)")
                }
            }
        }
    }
}
