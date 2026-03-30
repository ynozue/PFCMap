import SwiftUI
import MapKit
import Observation

@MainActor
@Observable
final class FirstPageModel {
    var cameraPosition: MapCameraPosition = .automatic
    var isLoading = false
    var errorMessage: String?
    
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
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        } catch {
            errorMessage = "現在地の取得に失敗しました。"
        }
    }
}
