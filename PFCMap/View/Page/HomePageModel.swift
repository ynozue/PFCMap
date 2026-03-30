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
    
    func onAppear(locationStore: LocationStore, shopCatalogStore: ShopCatalogStore) async {
        // カタログデータの初期読み込み
        Task {
            do {
                try await shopCatalogStore.load()
            } catch {
                print("Failed to load shop catalog: \(error)")
            }
        }
        
        // すでに取得済みの場合はスキップ
        if locationStore.currentLocation != nil { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await locationStore.fetchCurrentLocation()
            if let location = locationStore.currentLocation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        } catch {
            errorMessage = "現在地の取得に失敗しました。"
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
