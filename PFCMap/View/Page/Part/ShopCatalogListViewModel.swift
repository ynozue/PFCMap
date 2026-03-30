import SwiftUI

@MainActor
@Observable
class ShopCatalogListViewModel {
    var selectedShopIds: Set<String> = []
    
    init() {}
    
    func toggleSelection(id: String) {
        if selectedShopIds.contains(id) {
            selectedShopIds.remove(id)
        } else {
            selectedShopIds.insert(id)
        }
    }
    
    func selectAll(shops: [ShopCatalog]) {
        selectedShopIds = Set(shops.map { $0.id })
    }
    
    func isSelected(id: String) -> Bool {
        selectedShopIds.contains(id)
    }
}


