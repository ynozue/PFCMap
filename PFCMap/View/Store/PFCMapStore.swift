import SwiftUI
import Observation

@MainActor
@Observable
final class PFCMapStore {
    // データ毎のStoreを保持する
    @ObservationIgnored var locationStore: LocationStore
    @ObservationIgnored var shopSearchStore: ShopSearchStore
    @ObservationIgnored var shopCatalogStore: ShopCatalogStore
    @ObservationIgnored var settingsStore: SettingsStore
    
    var isInitialized: Bool = false

    init(factory: Factory) {
        // Factoryからリポジトリを取得してStoreの初期化など
        self.locationStore = LocationStore(
            locationRepository: factory.makeLocationRepository()
        )
        self.shopSearchStore = ShopSearchStore(
            shopSearchRepository: factory.makeShopSearchRepository()
        )
        let repository = factory.makeShopCatalogRepository()
        let remoteClient = factory.makePFCRemoteClient()
        self.shopCatalogStore = ShopCatalogStore(
            remoteClient: remoteClient,
            repository: repository
        )
        self.settingsStore = SettingsStore(
            userDefaultsService: factory.makeUserDefaultsService()
        )
    }
}
