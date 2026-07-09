import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class ShopSettingPageModel {
    let store: Store

    init(store: Store) {
        self.store = store
    }

    func onAppear() async {
        do {
            try await store.refreshShops()
            await store.loadSettings()
        } catch {
            print("Failed to fetch shops or settings in ShopSettingPage: \(error)")
        }
    }

    func toggleShopSetting(shopId: UUID) {
        Task {
            await store.toggleShopDisabled(shopId: shopId)
        }
    }

    func isShopEnabled(shopId: UUID) -> Bool {
        store.isShopEnabled(shopId: shopId)
    }
}
