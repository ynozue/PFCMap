import SwiftUI
import Observation

@MainActor
@Observable
final class ShopDetailPageModel {
    private(set) var shop: ShopCatalog
    
    init(shop: ShopCatalog) {
        self.shop = shop
    }
    
    func displayItems(proteinThreshold: ProteinThreshold, fatThreshold: FatThreshold) -> [ShopItem] {
        shop.items.filter { item in
            item.protein >= Double(proteinThreshold.rawValue) &&
            item.fat <= Double(fatThreshold.rawValue)
        }
    }
}
