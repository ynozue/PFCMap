import Foundation

public struct ShopResponseDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let menus: [MenuResponseDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, name, menus
    }
}

public struct MenuResponseDTO: Decodable, Sendable {
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
