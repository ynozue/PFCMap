import Foundation

protocol ShopCatalogRepository: Sendable {
    func sync(force: Bool) async throws
    func fetchShops() async throws -> [ShopCatalog]
    func addShop(_ shop: ShopCatalog) async throws
    func saveShops(_ shops: [ShopCatalog]) async throws
    func clearAll() async throws
    func reportItem(shopId: UUID, itemId: UUID, type: ShopItemReportType, imageData: Data?) async throws
    func updatePhotoData(itemId: UUID, data: Data?) async throws
}

extension ShopCatalogRepository {
    func reportItem(shopId: UUID, itemId: UUID, type: ShopItemReportType) async throws {
        try await reportItem(shopId: shopId, itemId: itemId, type: type, imageData: nil)
    }
}

extension ShopCatalogRepository {
    func sync() async throws {
        try await sync(force: false)
    }
}
