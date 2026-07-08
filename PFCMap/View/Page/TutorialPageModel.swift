import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class TutorialPageModel {
    var isFetchingShops = false
    var locationPermissionStatus: String = "未設定"

    let store: Store
    private let userDefaultsService: any UserDefaultsService
    private let locationRepository: any LocationRepository
    private let analyticsService: any AnalyticsService

    init(
        store: Store,
        userDefaultsService: any UserDefaultsService,
        locationRepository: any LocationRepository,
        analyticsService: any AnalyticsService
    ) {
        self.store = store
        self.userDefaultsService = userDefaultsService
        self.locationRepository = locationRepository
        self.analyticsService = analyticsService
    }

    func onAppear() async {
        isFetchingShops = true
        defer { isFetchingShops = false }

        do {
            try await store.refreshShops()
        } catch {
            print("Failed to fetch shops: \(error)")
        }
        await store.loadSettings()
    }

    func toggleShop(_ shop: ShopCatalog) {
        Task {
            await store.toggleShopDisabled(shopId: shop.id)
        }
    }
    
    func requestLocationPermission() async -> Bool {
        let isAuthorized = await locationRepository.requestAuthorization()
        if isAuthorized {
            locationPermissionStatus = "許可済み"
            locationRepository.prefetchLocation()
        } else {
            locationPermissionStatus = "未許可"
        }
        return isAuthorized
    }
    
    func completeTutorial(isTutorialCompleted: Binding<Bool>) async {
        await userDefaultsService.save(key: PFCMapUserDefaultsKeys.isTutorialCompleted, value: true)
        analyticsService.logTutorialComplete()
        isTutorialCompleted.wrappedValue = true
    }
}
