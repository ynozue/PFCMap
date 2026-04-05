import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class LocationStore {
    private(set) var currentLocation: Location?
    
    init() {}
    
    func updateCurrentLocation(_ location: Location) {
        self.currentLocation = location
    }
    
    func currentRegion(radius: Double = 1000) -> MKCoordinateRegion? {
        guard let location = currentLocation else { return nil }
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
    }
    
    func clear() {
        self.currentLocation = nil
    }
}
