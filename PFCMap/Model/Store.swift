import Foundation
import Observation
import NZData

/// アプリ全体で共有する状態（店舗カタログ・ユーザー設定）を一元管理する Store
/// PFCMapApp で生成し `.environment` 経由で配布する
/// バックグラウンド同期の完了も shops の更新として全画面へ自動反映される
@MainActor
@Observable
final class Store {
    // 店舗カタログ（DB から取得した削除済み除外後のデータ）
    var shops: [ShopCatalog] = []

    // ユーザー設定
    var mapDistance: MapDistance = .m500
    var proteinThreshold: ProteinThreshold = .g20
    var fatThreshold: FatThreshold = .g20
    var disabledShopIds: Set<UUID> = []

    private let factory: Factory

    // ModelContainer の初期化を伴うため、init では生成せず初回利用時に解決する
    // （warmupContainer によるバックグラウンド初期化を妨げないため）
    private var shopCatalogRepository: any ShopCatalogRepository { factory.makeShopCatalogRepository() }
    private var userDefaultsService: any UserDefaultsService { factory.makeUserDefaultsService() }

    init(factory: Factory) {
        self.factory = factory
    }

    // MARK: - Shops

    /// DB から店舗リストを再読込する
    func refreshShops() async throws {
        shops = try await shopCatalogRepository.fetchShops()
    }

    /// リモートと同期した上で店舗リストを再読込する
    func syncShops(force: Bool = false) async throws {
        try await shopCatalogRepository.sync(force: force)
        try await refreshShops()
    }

    // MARK: - Settings

    /// UserDefaults から設定値を読み込む
    func loadSettings() async {
        let distance: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.mapDistance)
        mapDistance = MapDistance(rawValue: distance) ?? .m500

        let protein: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.proteinThreshold)
        proteinThreshold = ProteinThreshold(rawValue: protein) ?? .g20

        let fat: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.fatThreshold)
        fatThreshold = FatThreshold(rawValue: fat) ?? .g20

        let ids: [String] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        disabledShopIds = Set(ids.compactMap { UUID(uuidString: $0) })
    }

    func updateMapDistance(_ distance: MapDistance) async {
        mapDistance = distance
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.mapDistance, value: distance.rawValue)
    }

    func updateProteinThreshold(_ threshold: ProteinThreshold) async {
        proteinThreshold = threshold
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: threshold.rawValue)
    }

    func updateFatThreshold(_ threshold: FatThreshold) async {
        fatThreshold = threshold
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: threshold.rawValue)
    }

    func toggleShopDisabled(shopId: UUID) async {
        if disabledShopIds.contains(shopId) {
            disabledShopIds.remove(shopId)
        } else {
            disabledShopIds.insert(shopId)
        }
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: disabledShopIds.map { $0.uuidString })
    }

    func isShopEnabled(shopId: UUID) -> Bool {
        !disabledShopIds.contains(shopId)
    }
}
