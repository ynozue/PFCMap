import Foundation

struct ShopCatalogResponseDTO: Codable, Sendable {
    let catalogs: [ShopCatalogDTO]
    
    init(catalogs: [ShopCatalogDTO]) {
        self.catalogs = catalogs
    }
    
    enum CodingKeys: String, CodingKey {
        case catalogs = "shops"
    }
}

struct ShopCatalogDTO: Codable, Sendable {
    let id: UUID
    let name: String
    let category: String?
    let description: String?
    let items: [ShopItemDTO]
    let createdAt: Date
    let updatedAt: Date
    let deleted: Bool
    
    init(
        id: UUID,
        name: String,
        category: String? = nil,
        description: String? = nil,
        items: [ShopItemDTO] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, description, items, createdAt, updatedAt, deleted
    }
}

struct ShopItemDTO: Codable, Sendable {
    let id: UUID
    let name: String
    let calorie: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    let createdAt: Date
    let updatedAt: Date
    let deleted: Bool
    
    init(
        id: UUID,
        name: String,
        calorie: Double,
        protein: Double,
        fat: Double,
        carbohydrate: Double,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.calorie = calorie
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, calorie, protein, fat, carbohydrate, createdAt, updatedAt, deleted
    }
}
