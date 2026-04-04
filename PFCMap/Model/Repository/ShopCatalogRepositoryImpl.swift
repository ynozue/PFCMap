import Foundation
import SwiftData
import NZData

actor ShopCatalogRepositoryImpl {
    private let remoteClient: any PFCRemoteClient
    private let dataOperator: DataOperator
    private let userDefaultsService: any UserDefaultsService
    
    init(remoteClient: any PFCRemoteClient, modelContainer: ModelContainer, userDefaultsService: any UserDefaultsService) {
        self.remoteClient = remoteClient
        self.dataOperator = DataOperator(modelContainer: modelContainer)
        self.userDefaultsService = userDefaultsService
    }
}

extension ShopCatalogRepositoryImpl: ShopCatalogRepository {
    func sync() async throws {
        let lastFetchDate: Date? = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
        let response = try await remoteClient.fetchShops(request: .init(lastFetchDate: lastFetchDate))
        let shops = response.catalogs.map { dto in
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
                        photoData: nil,
                        createdAt: item.createdAt,
                        updatedAt: item.updatedAt,
                        deleted: item.deleted
                    )
                },
                createdAt: dto.createdAt,
                updatedAt: dto.updatedAt,
                deleted: dto.deleted
            )
        }
        try await saveShops(shops)
        
        // 成功したら最終取得日時を更新
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.lastFetchedAt, value: Date())
    }

    func fetchShops() async throws -> [ShopCatalog] {
        try await dataOperator.fetchShops()
    }
    
    func addShop(_ shop: ShopCatalog) async throws {
        try await dataOperator.addShop(shop)
    }
    
    func saveShops(_ shops: [ShopCatalog]) async throws {
        try await dataOperator.saveShops(shops)
    }
    
    func clearAll() async throws {
        try await dataOperator.clearAll()
    }
}

private extension DataOperator {
    func fetchShops() async throws -> [ShopCatalog] {
        let descriptor = FetchDescriptor<ShopCatalogEntity>(
            predicate: #Predicate<ShopCatalogEntity> { !$0.deleted }
        )
        let entities = try modelContext.fetch(descriptor)
        return entities.map { entity in
            let domain = entity.toDomain()
            // item もフィルタリングする
            return ShopCatalog(
                id: domain.id,
                name: domain.name,
                category: domain.category,
                description: domain.description,
                items: domain.items.filter { !$0.deleted },
                createdAt: domain.createdAt,
                updatedAt: domain.updatedAt,
                deleted: domain.deleted
            )
        }
    }
    
    func addShop(_ shop: ShopCatalog) async throws {
        try await withTransaction {
            let entity = ShopCatalogEntity(
                id: shop.id,
                name: shop.name,
                category: shop.category,
                descriptionText: shop.description,
                items: [],
                createdAt: shop.createdAt,
                updatedAt: shop.updatedAt,
                deleted: shop.deleted
            )
            entity.items = shop.items.map { item in
                ShopItemEntity(
                    id: item.id,
                    name: item.name,
                    calorie: item.calorie,
                    protein: item.protein,
                    fat: item.fat,
                    carbohydrate: item.carbohydrate,
                    photoData: item.photoData,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt,
                    deleted: item.deleted
                )
            }
            try insert(entity)
        }
    }
    
    func saveShops(_ shops: [ShopCatalog]) async throws {
        try await withTransaction {
            for shop in shops {
                // 既存のショップを検索
                let shopId = shop.id
                let shopDescriptor = FetchDescriptor<ShopCatalogEntity>(
                    predicate: #Predicate<ShopCatalogEntity> { $0.id == shopId }
                )
                let existingShops = try modelContext.fetch(shopDescriptor)
                
                let entity: ShopCatalogEntity
                if let existing = existingShops.first {
                    // 更新
                    entity = existing
                    entity.name = shop.name
                    entity.category = shop.category
                    entity.descriptionText = shop.description
                    entity.updatedAt = shop.updatedAt
                    entity.deleted = shop.deleted
                } else {
                    // 新規作成
                    entity = ShopCatalogEntity(
                        id: shop.id,
                        name: shop.name,
                        category: shop.category,
                        descriptionText: shop.description,
                        createdAt: shop.createdAt,
                        updatedAt: shop.updatedAt,
                        deleted: shop.deleted
                    )
                    try insert(entity)
                }
                
                // アイテムの更新/追加
                // ShopItemEntity にも ID があるのでそれを利用する
                var currentItems = entity.items
                for item in shop.items {
                    if let existingItem = currentItems.first(where: { $0.id == item.id }) {
                        // 更新
                        existingItem.name = item.name
                        existingItem.calorie = item.calorie
                        existingItem.protein = item.protein
                        existingItem.fat = item.fat
                        existingItem.carbohydrate = item.carbohydrate
                        existingItem.photoData = item.photoData
                        existingItem.updatedAt = item.updatedAt
                        existingItem.deleted = item.deleted
                    } else {
                        // 新規追加
                        let newItem = ShopItemEntity(
                            id: item.id,
                            name: item.name,
                            calorie: item.calorie,
                            protein: item.protein,
                            fat: item.fat,
                            carbohydrate: item.carbohydrate,
                            photoData: item.photoData,
                            createdAt: item.createdAt,
                            updatedAt: item.updatedAt,
                            deleted: item.deleted
                        )
                        entity.items.append(newItem)
                    }
                }
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
