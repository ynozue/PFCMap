import SwiftUI
import Observation

@MainActor
@Observable
final class HomePageModel {
    var isLoading = false
    var errorMessage: String?
    var isMenuShowing = false
    var isMapShowing = false
    
    init() {}
    
    func onShopSelectionChange(shopIds: Set<UUID>, shopCatalogStore: ShopCatalogStore, shopSearchStore: ShopSearchStore) async {
        // 必要に応じて選択状態をStoreに反映させるロジックを追加
        // 現状はShopCatalogListView側で完結している想定
    }
}
