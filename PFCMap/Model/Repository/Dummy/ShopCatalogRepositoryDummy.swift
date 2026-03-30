import Foundation

public actor ShopCatalogRepositoryDummy: ShopCatalogRepository {
    private var shops: [ShopCatalog] = []
    
    public init() {}
    
    public func sync() async throws {
        // Dummy implementation for sync
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    public func fetchShops() async throws -> [ShopCatalog] {
        return shops
    }
    
    public func addShop(_ shop: ShopCatalog) async throws {
        shops.append(shop)
    }
    
    public func saveShops(_ shops: [ShopCatalog]) async throws {
        self.shops = shops
    }
    
    public func clearAll() async throws {
        shops.removeAll()
    }
}
