import Foundation

public struct ShopCatalog: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let category: String
    public let suitabilityMark: String
    public let description: String
    public let items: [ShopItem]
    
    public nonisolated init(
        id: String = UUID().uuidString,
        name: String,
        category: String = "",
        suitabilityMark: String = "",
        description: String = "",
        items: [ShopItem] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.suitabilityMark = suitabilityMark
        self.description = description
        self.items = items
    }
}
