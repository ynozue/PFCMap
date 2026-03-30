import Foundation

public protocol LocationRepository: Sendable {
    func requestLocation() async throws -> Location
}
