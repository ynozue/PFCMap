import Foundation

public protocol PFCRemoteClient: Sendable {
    func fetchShops() async throws -> [ShopCatalogResponseDTO]
}
