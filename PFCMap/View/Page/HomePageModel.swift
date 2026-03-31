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
                center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // 範囲を少し広げた
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
