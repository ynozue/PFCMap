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
    var selectedResultID: UUID? = nil
    
    init() {}
    
    func onAppear(locationStore: LocationStore, shopCatalogStore: ShopCatalogStore, shopSearchStore: ShopSearchStore, settingsStore: SettingsStore) {
        // スプラッシュですでに取得済みの現在地をカメラ位置に設定
        if let location = locationStore.currentLocation {
            let distance = Double(settingsStore.mapDistance.rawValue)
            let diameter = (distance + 100) * 2
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: diameter,
                longitudinalMeters: diameter
            ))
        }
        
        // 全ショップを地図上に検索して表示
        Task {
            let queries = shopCatalogStore.shops
                .filter { !settingsStore.disabledShopIds.contains($0.id) }
                .map { $0.name }
            if !queries.isEmpty {
                do {
                    try await shopSearchStore.search(queries: queries, region: visibleRegion)
                } catch {
                    print("Initial search failed: \(error)")
                }
            }
        }
    }
    
    func openInMaps(result: ShopSearchResult) {
        let coordinate = CLLocationCoordinate2D(
            latitude: result.location.latitude,
            longitude: result.location.longitude
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
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
}
