import Foundation

protocol ShopCatalogRepository: Sendable {
    func sync() async throws
    func fetchShops() async throws -> [ShopCatalog]
    func addShop(_ shop: ShopCatalog) async throws
    func saveShops(_ shops: [ShopCatalog]) async throws
    func clearAll() async throws
}
