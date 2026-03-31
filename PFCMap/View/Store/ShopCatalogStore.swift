import SwiftUI
import Observation

@MainActor
@Observable
final class ShopCatalogStore {
    private(set) var shops: [ShopCatalog] = []
    
    init() {}
    
    func updateShops(_ shops: [ShopCatalog]) {
        self.shops = shops
    }
}
