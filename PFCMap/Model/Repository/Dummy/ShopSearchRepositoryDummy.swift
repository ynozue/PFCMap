import Foundation
import MapKit

public actor ShopSearchRepositoryDummy: ShopSearchRepository {
    public init() {}
    
    public func search(queries: [String], region: MKCoordinateRegion?) async throws -> [ShopSearchResult] {
        // ダミーデータを返す
        return await MainActor.run {
            [
                ShopSearchResult(name: "マクドナルド 渋谷店", location: Location(latitude: 35.6586, longitude: 139.7011)),
                ShopSearchResult(name: "セブン-イレブン 渋谷駅前店", location: Location(latitude: 35.6596, longitude: 139.7021)),
                ShopSearchResult(name: "スターバックス コーヒー 渋谷公園通り店", location: Location(latitude: 35.6616, longitude: 139.7001))
            ]
        }
    }
}
