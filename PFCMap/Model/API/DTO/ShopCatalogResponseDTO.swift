import Foundation

public struct ShopCatalogResponseDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let category: String?
    public let suitabilityMark: String?
    public let description: String?
    public let items: [ShopItemResponseDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, description
        case suitabilityMark = "suitability_mark"
        case items = "menus"
    }
}

public struct ShopItemResponseDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let calorie: Double
    public let protein: Double
    public let fat: Double
    public let carbohydrate: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, calorie, protein, fat, carbohydrate
    }
}
