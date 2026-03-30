import SwiftUI
import Observation

@MainActor
@Observable
final class PFCMapStore {
    // データ毎のStoreを保持する
    @ObservationIgnored var locationStore: LocationStore
    @ObservationIgnored var shopSearchStore: ShopSearchStore
    @ObservationIgnored var shopCatalogStore: ShopCatalogStore
    
    init(factory: Factory) {
        // Factoryからリポジトリを取得してStoreの初期化など
        self.locationStore = LocationStore(locationRepository: factory.makeLocationRepository())
        self.shopSearchStore = ShopSearchStore(shopSearchRepository: factory.makeShopSearchRepository())
        self.shopCatalogStore = ShopCatalogStore(
            remoteClient: factory.makePFCRemoteClient(),
            repository: factory.makeShopCatalogRepository()
        )
    }
}
