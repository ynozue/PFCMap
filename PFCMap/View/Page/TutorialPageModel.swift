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
    
    private let shopCatalogRepository: any ShopCatalogRepository
    private let userDefaultsService: any UserDefaultsService
    private let locationRepository: any LocationRepository
    private let analyticsService: any AnalyticsService
    
    init(
        shopCatalogRepository: any ShopCatalogRepository,
        userDefaultsService: any UserDefaultsService,
        locationRepository: any LocationRepository,
        analyticsService: any AnalyticsService
    ) {
        self.shopCatalogRepository = shopCatalogRepository
        self.userDefaultsService = userDefaultsService
        self.locationRepository = locationRepository
        self.analyticsService = analyticsService
    }
    
    func onAppear() async {
        await fetchShops()
        await loadDisabledShopIds()
    }
    
    private func fetchShops() async {
        isFetchingShops = true
        defer { isFetchingShops = false }
        
        do {
            self.shops = try await shopCatalogRepository.fetchShops()
        } catch {
            print("Failed to fetch shops: \(error)")
        }
    }
    
    private func loadDisabledShopIds() async {
        let disabledIds = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        self.disabledShopIds = Set(disabledIds.compactMap { UUID(uuidString: $0) })
    }
    
    func toggleShop(_ shop: ShopCatalog) {
        if disabledShopIds.contains(shop.id) {
            disabledShopIds.remove(shop.id)
        } else {
            disabledShopIds.insert(shop.id)
        }
    }
    
    func saveDisabledShops() async {
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: disabledShopIds.map { $0.uuidString })
    }
    
    func requestLocationPermission() async {
        do {
            _ = try await locationRepository.requestLocation()
            locationPermissionStatus = "許可済み"
        } catch {
            print("Failed to request location: \(error)")
            locationPermissionStatus = "未許可またはエラー (\(error.localizedDescription))"
        }
    }
    
    func completeTutorial(isTutorialCompleted: Binding<Bool>) async {
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.isTutorialCompleted, value: true)
        analyticsService.logTutorialComplete()
        isTutorialCompleted.wrappedValue = true
    }
}
