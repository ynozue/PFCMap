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
    
    func onAppear(store: PFCMapStore) {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                // 現在地の取得
                let locationRepository = store.makeLocationRepository()
                let location = try await locationRepository.requestLocation()
                store.locationStore.updateCurrentLocation(location)
                
                // 現在地にカメラを移動
                updateCameraPosition(distance: store.settingsStore.mapDistance.rawValue, store: store)
                
                // 全ショップを地図上に検索して表示
                let queries = store.shopCatalogStore.shops
                    .filter { !store.settingsStore.disabledShopIds.contains($0.id) }
                    .map { $0.name }
                
                if !queries.isEmpty {
                    // PINは2,000m以内を表示するため、検索範囲を2,000m(+バッファ)にする
                    let radius = 2100.0
                    let searchRegion = visibleRegion ?? store.locationStore.currentRegion(radius: radius)
                    
                    let shopSearchRepository = store.makeShopSearchRepository()
                    let results = try await shopSearchRepository.search(queries: queries, region: searchRegion)
                    store.shopSearchStore.updateResults(results)
                }
            } catch {
                print("Initial data acquisition failed: \(error)")
                errorMessage = "情報の取得に失敗しました。\(error.localizedDescription)"
            }
        }
    }
    
    func updateCameraPosition(distance: Int, store: PFCMapStore) {
        guard let location = store.locationStore.currentLocation else { return }
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
}
