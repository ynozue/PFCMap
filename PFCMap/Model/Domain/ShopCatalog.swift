import Foundation

public struct ShopCatalog: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let items: [ShopItem]
    
    public nonisolated init(id: String = UUID().uuidString, name: String, items: [ShopItem] = []) {
        self.id = id
        self.name = name
        self.items = items
    }
}
