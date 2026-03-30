import Foundation

public actor LocationRepositoryDummy: LocationRepository {
    public init() {}
    
    public func requestLocation() async throws -> Location {
        // 東京タワー付近をダミーとして返す
        await Location(latitude: 35.6586, longitude: 139.7454)
    }
}
