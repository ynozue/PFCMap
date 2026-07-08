import Testing
import Foundation
import SwiftData
import NZData
@testable import PFCMap

// MARK: - Stubs

/// レスポンスを差し替え可能な PFCRemoteClient スタブ
private actor PFCRemoteClientStub: PFCRemoteClient {
    private var response = ShopCatalogResponseDTO(catalogs: [])
    private(set) var fetchCallCount = 0

    func setResponse(_ response: ShopCatalogResponseDTO) {
        self.response = response
    }

    func fetchShops(request: ShopCatalogRequestDTO) async throws -> ShopCatalogResponseDTO {
        fetchCallCount += 1
        return response
    }
}

private actor DiscordRemoteClientStub: DiscordRemoteClient {
    func sendNotification(content: String, imageData: Data?) async throws {}
}

/// lastFetchedAt をメモリ上で保持する UserDefaultsService スタブ
private actor UserDefaultsServiceStub: UserDefaultsService {
    private var lastFetchedAt: Date?

    func setLastFetchedAt(_ date: Date?) {
        lastFetchedAt = date
    }

    func save<T>(key: UserDefaultsKey<T>, value: T) async where T: Sendable {
        if let date = value as? Date {
            lastFetchedAt = date
        }
    }

    func value<T>(key: UserDefaultsKey<T>) async -> T where T: Sendable {
        if let value = lastFetchedAt as? T {
            return value
        }
        return key.defaultValue
    }

    func remove<T>(key: UserDefaultsKey<T>) async where T: Sendable {
        lastFetchedAt = nil
    }

    func removeAll() async {
        lastFetchedAt = nil
    }
}

// MARK: - Tests

@Suite("ShopCatalogRepositoryImpl")
struct ShopCatalogRepositoryImplTests {
    private let remoteClient: PFCRemoteClientStub
    private let userDefaultsService: UserDefaultsServiceStub
    private let repository: ShopCatalogRepositoryImpl

    init() throws {
        remoteClient = PFCRemoteClientStub()
        userDefaultsService = UserDefaultsServiceStub()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self, configurations: config)
        repository = ShopCatalogRepositoryImpl(
            remoteClient: remoteClient,
            discordRemoteClient: DiscordRemoteClientStub(),
            modelContainer: container,
            userDefaultsService: userDefaultsService
        )
    }

    @Test("初回 sync で店舗が保存され、削除済みショップ・アイテムは fetchShops から除外される")
    func syncSavesShopsAndFiltersDeleted() async throws {
        let shopId = UUID()
        await remoteClient.setResponse(ShopCatalogResponseDTO(catalogs: [
            ShopCatalogDTO(
                id: shopId, name: "テスト屋",
                items: [
                    ShopItemDTO(id: UUID(), name: "生存メニュー", calorie: 500, protein: 30, fat: 10, carbohydrate: 50, type: ShopItem.stapleFoodType),
                    ShopItemDTO(id: UUID(), name: "削除済みメニュー", calorie: 0, protein: 0, fat: 0, carbohydrate: 0, deleted: true)
                ]
            ),
            ShopCatalogDTO(id: UUID(), name: "削除済みショップ", deleted: true)
        ]))

        try await repository.sync(force: false)
        let shops = try await repository.fetchShops()

        #expect(shops.count == 1)
        #expect(shops.first?.id == shopId)
        #expect(shops.first?.items.map(\.name) == ["生存メニュー"])
    }

    @Test("既存アイテムが deleted になった差分 sync が fetchShops に反映される")
    func deletedFlagUpdateIsReflected() async throws {
        let shopId = UUID()
        let itemId = UUID()
        await remoteClient.setResponse(ShopCatalogResponseDTO(catalogs: [
            ShopCatalogDTO(
                id: shopId, name: "テスト屋",
                items: [
                    ShopItemDTO(id: itemId, name: "かつぶしオクラ牛丼ライト(ミニ)", calorie: 300, protein: 20, fat: 8, carbohydrate: 30, type: ShopItem.stapleFoodType)
                ]
            )
        ]))
        try await repository.sync(force: false)

        // サーバー側で deleted になった差分レスポンス
        await remoteClient.setResponse(ShopCatalogResponseDTO(catalogs: [
            ShopCatalogDTO(
                id: shopId, name: "テスト屋",
                items: [
                    ShopItemDTO(id: itemId, name: "かつぶしオクラ牛丼ライト(ミニ)", calorie: 300, protein: 20, fat: 8, carbohydrate: 30, type: ShopItem.stapleFoodType, deleted: true)
                ]
            )
        ]))
        try await repository.sync(force: true)

        let shops = try await repository.fetchShops()
        #expect(shops.first?.items.isEmpty == true)
    }

    @Test("最終同期から20時間以内は sync がスキップされる")
    func syncIsSkippedWithinInterval() async throws {
        await userDefaultsService.setLastFetchedAt(Date().addingTimeInterval(-3600)) // 1時間前

        try await repository.sync(force: false)

        #expect(await remoteClient.fetchCallCount == 0)
    }

    @Test("force 指定なら期間内でも sync が実行される")
    func forceSyncBypassesInterval() async throws {
        await userDefaultsService.setLastFetchedAt(Date().addingTimeInterval(-3600)) // 1時間前

        try await repository.sync(force: true)

        #expect(await remoteClient.fetchCallCount == 1)
    }

    @Test("sync 成功後に lastFetchedAt が更新される")
    func syncUpdatesLastFetchedAt() async throws {
        try await repository.sync(force: false)

        let saved: Date? = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
        #expect(saved != nil)
    }
}

// MARK: - SwiftData の deleted プロパティ名衝突（NSManagedObject.isDeleted）の回帰テスト

@Suite("ShopItemEntity 削除フラグ")
struct DeletedPropertyTests {
    @Test("deleted=true で保存した ShopItemEntity は save 後も true を保持する")
    func deletedRoundTrip() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self, configurations: config)
        let context = ModelContext(container)

        let item = ShopItemEntity(id: UUID(), name: "test", calorie: 1, protein: 1, fat: 1, carbohydrate: 1, deleted: true)
        context.insert(item)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ShopItemEntity>())
        #expect(fetched.first?.isRemoved == true)
    }
}
