import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class LocationStore {
    var currentLocation: Location?
    private let locationRepository: any LocationRepository
    
    init(locationRepository: any LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    func fetchCurrentLocation() async throws {
        self.currentLocation = try await locationRepository.requestLocation()
    }
    
    func currentRegion(radius: Double = 1000) -> MKCoordinateRegion? {
        guard let location = currentLocation else { return nil }
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
    }
}
