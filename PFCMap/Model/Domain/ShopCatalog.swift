import Foundation

public struct ShopCatalog: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let category: ShopCategory
    public let description: String
    public let items: [ShopItem]
    
    public nonisolated init(
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
