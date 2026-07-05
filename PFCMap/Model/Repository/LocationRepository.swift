import Foundation

protocol LocationRepository: Sendable {
    func requestLocation() async throws -> Location
    func prefetchLocation()
    func requestAuthorization() async -> Bool
}
