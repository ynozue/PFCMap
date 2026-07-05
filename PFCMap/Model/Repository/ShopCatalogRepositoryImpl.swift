import Foundation
import SwiftData
import NZData

actor ShopCatalogRepositoryImpl {
    private let remoteClient: any PFCRemoteClient
    private let discordRemoteClient: any DiscordRemoteClient
    private let dataOperator: DataOperator
    private let userDefaultsService: any UserDefaultsService
    
    init(remoteClient: any PFCRemoteClient, discordRemoteClient: any DiscordRemoteClient, modelContainer: ModelContainer, userDefaultsService: any UserDefaultsService) {
        self.remoteClient = remoteClient
        self.discordRemoteClient = discordRemoteClient
        self.dataOperator = DataOperator(modelContainer: modelContainer)
        self.userDefaultsService = userDefaultsService
    }
}

extension ShopCatalogRepositoryImpl: ShopCatalogRepository {
    func sync(force: Bool = false) async throws {
        let lastFetchDate: Date? = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
        
        if !force, let lastFetchDate = lastFetchDate, Date().timeIntervalSince(lastFetchDate) < 72000 {
            print("Skip sync: Last sync was less than 20 hours ago.")
            return
        }
        
        let response = try await remoteClient.fetchShops(request: .init(lastFetchDate: lastFetchDate))
        let shops = await response.toDomain()
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

    func reportItem(shopId: UUID, itemId: UUID, type: ShopItemReportType, imageData: Data?) async throws {
        // ショップ情報を取得
        let shops = try await fetchShops()
        guard let shop = shops.first(where: { $0.id == shopId }),
              let item = shop.items.first(where: { $0.id == itemId }) else {
            return
        }
        
        let message = """
        🚨 **フィードバックが届きました**
        
        **報告種別**: \(await type.label)
        **店舗名**: \(shop.name)
        **メニュー名**: \(item.name)
        
        ---
        **Shop ID**: `\(shopId.uuidString)`
        **Item ID**: `\(itemId.uuidString)`
        """
        
        try await discordRemoteClient.sendNotification(content: message, imageData: imageData)
    }

    func updatePhotoData(itemId: UUID, data: Data?) async throws {
        try await dataOperator.updatePhotoData(itemId: itemId, data: data)
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
                type: domain.type,
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
                type: shop.type,
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
                    type: item.type,
                    url: item.url,
                    photoURL: item.photoURL,
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
                    entity.type = shop.type
                    entity.updatedAt = shop.updatedAt
                    entity.deleted = shop.deleted
                } else {
                    // 新規作成
                    entity = ShopCatalogEntity(
                        id: shop.id,
                        name: shop.name,
                        category: shop.category,
                        descriptionText: shop.description,
                        type: shop.type,
                        createdAt: shop.createdAt,
                        updatedAt: shop.updatedAt,
                        deleted: shop.deleted
                    )
                    try insert(entity)
                }
                
                // アイテムの更新/追加
                for item in shop.items {
                    let itemId = item.id
                    let itemDescriptor = FetchDescriptor<ShopItemEntity>(
                        predicate: #Predicate<ShopItemEntity> { $0.id == itemId }
                    )
                    let foundItems = try modelContext.fetch(itemDescriptor)
                    
                    if let existingItem = foundItems.first {
                        // 更新
                        existingItem.name = item.name
                        existingItem.calorie = item.calorie
                        existingItem.protein = item.protein
                        existingItem.fat = item.fat
                        existingItem.carbohydrate = item.carbohydrate
                        existingItem.type = item.type
                        existingItem.url = item.url
                        
                        // URLが変わった場合のみ、写真データを破棄して再ダウンロードを促す
                        if existingItem.photoURL != item.photoURL {
                            existingItem.photoURL = item.photoURL
                            existingItem.photoData = nil
                        }
                        
                        existingItem.updatedAt = item.updatedAt
                        existingItem.deleted = item.deleted
                        
                        // リレーションに追加されていない場合は追加（基本的には入っているはずだが念のため）
                        if !entity.items.contains(where: { $0.id == itemId }) {
                            entity.items.append(existingItem)
                        }
                    } else {
                        // 新規追加
                        let newItem = ShopItemEntity(
                            id: item.id,
                            name: item.name,
                            calorie: item.calorie,
                            protein: item.protein,
                            fat: item.fat,
                            carbohydrate: item.carbohydrate,
                            type: item.type,
                            url: item.url,
                            photoURL: item.photoURL,
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
    
    func updatePhotoData(itemId: UUID, data: Data?) async throws {
        try await withTransaction {
            let descriptor = FetchDescriptor<ShopItemEntity>(
                predicate: #Predicate<ShopItemEntity> { $0.id == itemId }
            )
            if let entity = try modelContext.fetch(descriptor).first {
                entity.photoData = data
            }
        }
    }
}
