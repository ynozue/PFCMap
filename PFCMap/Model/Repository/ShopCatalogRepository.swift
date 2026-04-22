import Foundation

protocol ShopCatalogRepository: Sendable {
    func sync(force: Bool) async throws
    func fetchShops() async throws -> [ShopCatalog]
    func addShop(_ shop: ShopCatalog) async throws
    func saveShops(_ shops: [ShopCatalog]) async throws
    func clearAll() async throws
    func reportItem(shopId: UUID, itemId: UUID, type: ShopItemReportType) async throws
}

extension ShopCatalogRepository {
    func sync() async throws {
        try await sync(force: false)
    }
}
