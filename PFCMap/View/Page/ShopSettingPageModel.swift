import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class ShopSettingPageModel {
    var shops: [ShopCatalog] = []
    var disabledShopIds: Set<UUID> = []
    
    private let shopCatalogRepository: any ShopCatalogRepository
    private let userDefaultsService: any UserDefaultsService
    
    init(shopCatalogRepository: any ShopCatalogRepository, userDefaultsService: any UserDefaultsService) {
        self.shopCatalogRepository = shopCatalogRepository
        self.userDefaultsService = userDefaultsService
    }
    
    func onAppear() async {
        do {
            self.shops = try await shopCatalogRepository.fetchShops()
            
            let ids: [String] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
            self.disabledShopIds = Set(ids.compactMap { UUID(uuidString: $0) })
        } catch {
            print("Failed to fetch shops or settings in ShopSettingPage: \(error)")
        }
    }
    
    func toggleShopSetting(shopId: UUID) {
        if disabledShopIds.contains(shopId) {
            disabledShopIds.remove(shopId)
        } else {
            disabledShopIds.insert(shopId)
        }
        
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: self.disabledShopIds.map { $0.uuidString })
        }
    }
    
    func isShopEnabled(shopId: UUID) -> Bool {
        !disabledShopIds.contains(shopId)
    }
}
