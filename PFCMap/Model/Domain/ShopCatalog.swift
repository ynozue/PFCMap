import Foundation

struct ShopCatalog: Sendable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ShopCategory
    let description: String
    let type: Int
    let items: [ShopItem]
    
    let createdAt: Date
    let updatedAt: Date
    let deleted: Bool
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        category: ShopCategory = .other,
        description: String = "",
        type: Int = 0,
        items: [ShopItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.type = type
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}
