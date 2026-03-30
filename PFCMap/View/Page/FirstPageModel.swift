import SwiftUI
import MapKit
import Observation

@MainActor
@Observable
final class FirstPageModel {
    var cameraPosition: MapCameraPosition = .automatic
    var isLoading = false
    var isLoadingSearch = false
    var errorMessage: String?
    var searchText: String = ""
    
    init() {}
    
    func onAppear(locationStore: LocationStore) async {
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
    
    func searchShops(shopSearchStore: ShopSearchStore) async {
        guard !searchText.isEmpty else { return }
        
        isLoadingSearch = true
        defer { isLoadingSearch = false }
        
        do {
            // 現在の表示領域内を優先して検索する
            let region = cameraPosition.region
            try await shopSearchStore.search(query: searchText, region: region)
            
            // 検索結果がある場合は最初の結果に合わせてカメラを移動する（任意）
            if let firstShop = shopSearchStore.shops.first {
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: firstShop.location.latitude, longitude: firstShop.location.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        } catch {
            errorMessage = "検索に失敗しました。"
        }
    }
    
    func clearSearch(shopSearchStore: ShopSearchStore) {
        searchText = ""
        shopSearchStore.clear()
    }
}
