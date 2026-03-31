import Foundation

struct ShopCatalog: Sendable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ShopCategory
    let description: String
    let items: [ShopItem]
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        category: ShopCategory = .other,
        description: String = "",
        items: [ShopItem] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.items = items
    }
}
