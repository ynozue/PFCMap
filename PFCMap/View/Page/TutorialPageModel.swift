import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class TutorialPageModel {
    var shops: [ShopCatalog] = []
    var disabledShopIds: Set<UUID> = []
    var isFetchingShops = false
    var locationPermissionStatus: String = "未設定"
    
    init() {}
    
    func onAppear(factory: Factory) async {
        await fetchShops(factory: factory)
        await loadDisabledShopIds(factory: factory)
    }
    
    private func fetchShops(factory: Factory) async {
        isFetchingShops = true
        defer { isFetchingShops = false }
        
        do {
            let repository = factory.makeShopCatalogRepository()
            self.shops = try await repository.fetchShops()
        } catch {
            print("Failed to fetch shops: \(error)")
        }
    }
    
    private func loadDisabledShopIds(factory: Factory) async {
        let defaultsService = factory.makeUserDefaultsService()
        let disabledIds = await defaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        self.disabledShopIds = Set(disabledIds.compactMap { UUID(uuidString: $0) })
    }
    
    func toggleShop(_ shop: ShopCatalog, factory: Factory) {
        if disabledShopIds.contains(shop.id) {
            disabledShopIds.remove(shop.id)
        } else {
            disabledShopIds.insert(shop.id)
        }
    }
    
    func saveDisabledShops(factory: Factory) async {
        let defaultsService = factory.makeUserDefaultsService()
        await defaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: disabledShopIds.map { $0.uuidString })
    }
    
    func requestLocationPermission(factory: Factory) async {
        do {
            let locationRepo = factory.makeLocationRepository()
            _ = try await locationRepo.requestLocation()
            locationPermissionStatus = "許可済み"
        } catch {
            print("Failed to request location: \(error)")
            locationPermissionStatus = "未許可またはエラー (\(error.localizedDescription))"
        }
    }
    
    func completeTutorial(factory: Factory, isTutorialCompleted: Binding<Bool>) async {
        let defaultsService = factory.makeUserDefaultsService()
        await defaultsService.save(key: PFCMapUserDefaultsKeys.isTutorialCompleted, value: true)
        isTutorialCompleted.wrappedValue = true
    }
}
