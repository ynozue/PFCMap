import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class ShopSettingPageModel {
    var shops: [ShopCatalog] = []
    var disabledShopIds: Set<UUID> = []
    
    init() {}
    
    func onAppear(factory: Factory) async {
        do {
            let shopCatalogRepository = factory.makeShopCatalogRepository()
            self.shops = try await shopCatalogRepository.fetchShops()
            
            let service = factory.makeUserDefaultsService()
            let ids: [String] = await service.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
            self.disabledShopIds = Set(ids.compactMap { UUID(uuidString: $0) })
        } catch {
            print("Failed to fetch shops or settings in ShopSettingPage: \(error)")
        }
    }
    
    func toggleShopSetting(shopId: UUID, factory: Factory) {
        if disabledShopIds.contains(shopId) {
            disabledShopIds.remove(shopId)
        } else {
            disabledShopIds.insert(shopId)
        }
        
        let service = factory.makeUserDefaultsService()
        Task {
            await service.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: self.disabledShopIds.map { $0.uuidString })
        }
    }
    
    func isShopEnabled(shopId: UUID) -> Bool {
        !disabledShopIds.contains(shopId)
    }
}
