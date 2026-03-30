import Foundation
import MapKit

public actor ShopSearchRepositoryDummy: ShopSearchRepository {
    public init() {}
    
    public func search(query: String, region: MKCoordinateRegion?) async throws -> [Shop] {
        // ダミーデータを返す
        return [
            Shop(name: "マクドナルド 渋谷店", location: Location(latitude: 35.6586, longitude: 139.7011)),
            Shop(name: "セブン-イレブン 渋谷駅前店", location: Location(latitude: 35.6596, longitude: 139.7021)),
            Shop(name: "スターバックス コーヒー 渋谷公園通り店", location: Location(latitude: 35.6616, longitude: 139.7001))
        ]
    }
}
