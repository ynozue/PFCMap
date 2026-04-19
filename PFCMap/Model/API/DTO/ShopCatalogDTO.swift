import Foundation

actor ShopCatalogDTO: Decodable, Sendable {
    let id: UUID
    let name: String
    let category: String?
    let description: String?
    let type: Int
    let items: [ShopItemDTO]
    let createdAt: Date
    let updatedAt: Date
    let deleted: Bool
    
    init(
        id: UUID,
        name: String,
        category: String? = nil,
        description: String? = nil,
        type: Int = 0,
        items: [ShopItemDTO] = [],
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
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, description, type, items, createdAt, updatedAt, deleted
    }
}

extension ShopCatalogDTO {
    func toDomain() async -> ShopCatalog {
        var domainItems: [ShopItem] = []
        for item in items {
            domainItems.append(await item.toDomain())
        }
        
        return ShopCatalog(
            id: id,
            name: name,
            category: category.flatMap(ShopCategory.init(rawValue:)) ?? .other,
            description: description ?? "",
            type: type,
            items: domainItems,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted
        )
    }
}
