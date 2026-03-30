import SwiftUI
import Observation

@MainActor
@Observable
final class ShopItemListPageModel {
    let shop: ShopCatalog
    
    init(shop: ShopCatalog) {
        self.shop = shop
    }
}
