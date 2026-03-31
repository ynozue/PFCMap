import Foundation
import MapKit

public actor ShopSearchRepositoryDummy: ShopSearchRepository {
    public init() {}
    
    public func search(queries: [String], region: MKCoordinateRegion?) async throws -> [ShopSearchResult] {
        // ダミーデータを返す
        return await MainActor.run {
            [
                ShopSearchResult(name: "サイゼリヤ 渋谷道玄坂店", query: "サイゼリヤ", location: Location(latitude: 35.6596, longitude: 139.6991)),
                ShopSearchResult(name: "ガスト 渋谷駅前店", query: "ガスト", location: Location(latitude: 35.6586, longitude: 139.7011)),
                ShopSearchResult(name: "大戸屋 渋谷文化村通り店", query: "大戸屋", location: Location(latitude: 35.6616, longitude: 139.6981))
            ]
        }
    }
}
