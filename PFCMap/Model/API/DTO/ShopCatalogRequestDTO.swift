import Foundation

/// ショップカタログ取得のリクエストDTO
struct ShopCatalogRequestDTO: Encodable, Sendable {
    /// 最終取得日時
    let lastFetchDate: Date?
    
    init(lastFetchDate: Date? = nil) {
        self.lastFetchDate = lastFetchDate
    }
    
    enum CodingKeys: String, CodingKey {
        case lastFetchDate = "last_fetch_date"
    }
}
