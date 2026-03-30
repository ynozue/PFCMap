import SwiftUI
import Observation

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
}
