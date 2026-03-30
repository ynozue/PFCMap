import Foundation

public protocol ShopCatalogRepository: Sendable {
    func fetchShops() async throws -> [Shop]
    func addShop(_ shop: Shop) async throws
    func saveShops(_ shops: [Shop]) async throws
    func clearAll() async throws
}
