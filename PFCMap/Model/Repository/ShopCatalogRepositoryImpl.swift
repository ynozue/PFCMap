import Foundation
import SwiftData
import NZData

public actor ShopCatalogRepositoryImpl {
    private let remoteClient: any PFCRemoteClient
    private let dataOperator: DataOperator
    
    public init(remoteClient: any PFCRemoteClient, modelContainer: ModelContainer) {
        self.remoteClient = remoteClient
        self.dataOperator = DataOperator(modelContainer: modelContainer)
    }
}

extension ShopCatalogRepositoryImpl: ShopCatalogRepository {
    public func sync() async throws {
        let dtos = try await remoteClient.fetchShops()
        let shops = dtos.map { dto in
            ShopCatalog(
                id: dto.id,
                name: dto.name,
                category: dto.category.flatMap(ShopCategory.init(rawValue:)) ?? .other,
                description: dto.description ?? "",
                items: dto.items.map { item in
                    ShopItem(
                        id: item.id,
                        name: item.name,
                        calorie: item.calorie,
                        protein: item.protein,
                        fat: item.fat,
                        carbohydrate: item.carbohydrate,
                        photoData: nil
                    )
                }
            )
        }
        try await saveShops(shops)
    }

    public func fetchShops() async throws -> [ShopCatalog] {
        try await dataOperator.fetchShops()
    }
    
    public func addShop(_ shop: ShopCatalog) async throws {
        try await dataOperator.addShop(shop)
    }
    
    public func saveShops(_ shops: [ShopCatalog]) async throws {
        try await dataOperator.saveShops(shops)
    }
    
    public func clearAll() async throws {
        try await dataOperator.clearAll()
    }
}

private extension DataOperator {
    func fetchShops() async throws -> [ShopCatalog] {
        try await fetch(ShopCatalogEntity.self)
    }
    
    func addShop(_ shop: ShopCatalog) async throws {
        try await withTransaction {
            let entity = ShopCatalogEntity(
                id: shop.id,
                name: shop.name,
                category: shop.category,
                descriptionText: shop.description,
                items: []
            )
            entity.items = shop.items.map { item in
                ShopItemEntity(
                    id: item.id,
                    name: item.name,
                    calorie: item.calorie,
                    protein: item.protein,
                    fat: item.fat,
                    carbohydrate: item.carbohydrate,
                    photoData: item.photoData
                )
            }
            try insert(entity)
        }
    }
    
    func saveShops(_ shops: [ShopCatalog]) async throws {
        try await withTransaction {
            // Delete existing
            let existing = try modelContext.fetch(FetchDescriptor<ShopCatalogEntity>())
            try delete(existing)
            
            for shop in shops {
                let entity = ShopCatalogEntity(
                    id: shop.id,
                    name: shop.name,
                    category: shop.category,
                    descriptionText: shop.description
                )
                entity.items = shop.items.map { item in
                    ShopItemEntity(
                        id: item.id,
                        name: item.name,
                        calorie: item.calorie,
                        protein: item.protein,
                        fat: item.fat,
                        carbohydrate: item.carbohydrate,
                        photoData: item.photoData
                    )
                }
                try insert(entity)
            }
        }
    }
    
    func clearAll() async throws {
        try await withTransaction {
            let existing = try modelContext.fetch(FetchDescriptor<ShopCatalogEntity>())
            try delete(existing)
        }
    }
}
