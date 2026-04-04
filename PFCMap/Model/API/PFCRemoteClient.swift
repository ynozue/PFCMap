import Foundation

protocol PFCRemoteClient: Sendable {
    /// ショップ一覧を取得する
    /// - Parameter request: リクエストDTO
    /// - Returns: ショップカタログのレスポンスDTO配列
    func fetchShops(request: ShopCatalogRequestDTO) async throws -> ShopCatalogResponseDTO
}
