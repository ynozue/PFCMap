import Foundation

actor LocationRepositoryDummy: LocationRepository {
    init() {}
    
    func requestLocation() async throws -> Location {
        // 東京タワー付近をダミーとして返す
        Location(latitude: 35.6586, longitude: 139.7454)
    }
    
    nonisolated func prefetchLocation() {
        // ダミーのため何もしない
    }
    
    func requestAuthorization() async -> Bool {
        return true
    }
}
