import Foundation

protocol PFCRemoteClient: Sendable {
    func fetchShops() async throws -> [ShopCatalogResponseDTO]
}
