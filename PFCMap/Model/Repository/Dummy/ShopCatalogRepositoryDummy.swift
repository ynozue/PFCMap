import Foundation

public actor ShopCatalogRepositoryDummy: ShopCatalogRepository {
    private var shops: [Shop] = []
    
    public init() {}
    
    public func fetchShops() async throws -> [Shop] {
        return shops
    }
    
    public func addShop(_ shop: Shop) async throws {
        shops.append(shop)
    }
    
    public func saveShops(_ shops: [Shop]) async throws {
        self.shops = shops
    }
    
    public func clearAll() async throws {
        shops.removeAll()
    }
}
