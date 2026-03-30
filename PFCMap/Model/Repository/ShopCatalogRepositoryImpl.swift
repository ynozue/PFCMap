import Foundation
import SwiftData
import NZData

public actor ShopCatalogRepositoryImpl {
    private let dataOperator: DataOperator
    
    public init(modelContainer: ModelContainer) {
        self.dataOperator = DataOperator(modelContainer: modelContainer)
    }
}

extension ShopCatalogRepositoryImpl: ShopCatalogRepository {
    public func fetchShops() async throws -> [Shop] {
        try await dataOperator.fetchShops()
    }
    
    public func addShop(_ shop: Shop) async throws {
        try await dataOperator.addShop(shop)
    }
    
    public func saveShops(_ shops: [Shop]) async throws {
        try await dataOperator.saveShops(shops)
    }
    
    public func clearAll() async throws {
        try await dataOperator.clearAll()
    }
}

private extension DataOperator {
    func fetchShops() async throws -> [Shop] {
        try await fetch(ShopEntity.self)
    }
    
    func addShop(_ shop: Shop) async throws {
        try await withTransaction {
            let entity = ShopEntity(id: shop.id, name: shop.name)
            entity.menus = shop.menus.map { menu in
                MenuEntity(
                    id: menu.id,
                    name: menu.name,
                    calorie: menu.calorie,
                    protein: menu.protein,
                    fat: menu.fat,
                    carbohydrate: menu.carbohydrate,
                    photoData: menu.photoData
                )
            }
            try insert(entity)
        }
    }
    
    func saveShops(_ shops: [Shop]) async throws {
        try await withTransaction {
            // Delete existing
            let existing = try modelContext.fetch(FetchDescriptor<ShopEntity>())
            try delete(existing)
            
            for shop in shops {
                let entity = ShopEntity(id: shop.id, name: shop.name)
                entity.menus = shop.menus.map { menu in
                    MenuEntity(
                        id: menu.id,
                        name: menu.name,
                        calorie: menu.calorie,
                        protein: menu.protein,
                        fat: menu.fat,
                        carbohydrate: menu.carbohydrate,
                        photoData: menu.photoData
                    )
                }
                try insert(entity)
            }
        }
    }
    
    func clearAll() async throws {
        try await withTransaction {
            let existing = try modelContext.fetch(FetchDescriptor<ShopEntity>())
            try delete(existing)
        }
    }
}
