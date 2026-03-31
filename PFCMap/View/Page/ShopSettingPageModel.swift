import SwiftUI
import Observation

@MainActor
@Observable
final class ShopSettingPageModel {
    // 画面固有のUI状態があればここに追加（例：検索バーのテキストなど）
    
    init() {}
    
    func toggleShopSetting(shopId: UUID, store: PFCMapStore) {
        var disabledIds = store.settingsStore.disabledShopIds
        if disabledIds.contains(shopId) {
            disabledIds.remove(shopId)
        } else {
            disabledIds.insert(shopId)
        }
        store.settingsStore.updateDisabledShopIds(disabledIds)
    }
    
    func isShopEnabled(shopId: UUID, store: PFCMapStore) -> Bool {
        !store.settingsStore.disabledShopIds.contains(shopId)
    }
}
