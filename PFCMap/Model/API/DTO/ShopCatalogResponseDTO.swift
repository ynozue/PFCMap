import Foundation

struct ShopCatalogResponseDTO: Decodable, Sendable {
    let id: UUID
    let name: String
    let category: String?
    let description: String?
    let items: [ShopItemResponseDTO]
    
    init(
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

struct ShopItemResponseDTO: Decodable, Sendable {
    let id: UUID
    let name: String
    let calorie: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    
    init(
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
