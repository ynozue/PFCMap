import Foundation

public struct ShopCatalogResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String
    public let category: String?
    public let description: String?
    public let items: [ShopItemResponseDTO]
    
    public init(
        id: UUID,
        name: String,
        category: String? = nil,
        description: String? = nil,
        items: [ShopItemResponseDTO] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.items = items
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, description
        case items = "menus"
    }
}

public struct ShopItemResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String
    public let calorie: Double
    public let protein: Double
    public let fat: Double
    public let carbohydrate: Double
    
    public init(
        id: UUID,
        name: String,
        calorie: Double,
        protein: Double,
        fat: Double,
        carbohydrate: Double
    ) {
        self.id = id
        self.name = name
        self.calorie = calorie
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, calorie, protein, fat, carbohydrate
    }
}
