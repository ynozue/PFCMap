import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class PFCMapStore {
    // Factoryを保持する
    private let factory: Factory
    
    // データ毎のStoreを保持する
    @ObservationIgnored let locationStore: LocationStore
    @ObservationIgnored let shopSearchStore: ShopSearchStore
    @ObservationIgnored let shopCatalogStore: ShopCatalogStore
    @ObservationIgnored let settingsStore: SettingsStore
    
    var isInitialized: Bool = false

    init(factory: Factory) {
        self.factory = factory
        self.locationStore = LocationStore()
        self.shopSearchStore = ShopSearchStore()
        self.shopCatalogStore = ShopCatalogStore()
        self.settingsStore = SettingsStore()
    }
    
    func makeLocationRepository() -> any LocationRepository {
        factory.makeLocationRepository()
    }
    
    func makeShopSearchRepository() -> any ShopSearchRepository {
        factory.makeShopSearchRepository()
    }
    
    func makeShopCatalogRepository() -> any ShopCatalogRepository {
        factory.makeShopCatalogRepository()
    }
    
    func makeUserDefaultsService() -> any UserDefaultsService {
        factory.makeUserDefaultsService()
    }
    
    func clearAllData() {
        locationStore.clear()
        shopSearchStore.clear()
        shopCatalogStore.clear()
        settingsStore.reset()
        isInitialized = false
    }
}
