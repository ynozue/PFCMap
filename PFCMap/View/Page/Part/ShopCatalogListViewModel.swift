import SwiftUI

@MainActor
@Observable
class ShopCatalogListViewModel {
    var selectedShopIds: Set<UUID> = []
    
    init() {}
    
    func toggleSelection(id: UUID) {
        if selectedShopIds.contains(id) {
            selectedShopIds.remove(id)
        } else {
            selectedShopIds.insert(id)
        }
    }
    
    func selectAll(shops: [ShopCatalog]) {
        selectedShopIds = Set(shops.map { $0.id })
    }
    
    func isSelected(id: UUID) -> Bool {
        selectedShopIds.contains(id)
    }
}


