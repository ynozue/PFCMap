import Foundation

actor ShopItemDTO: Decodable, Sendable {
    let id: UUID
    let name: String
    let calorie: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    let type: String
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
        type: String = "",
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
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, calorie, protein, fat, carbohydrate, type, createdAt, updatedAt, deleted
    }
}

extension ShopItemDTO {
    func toDomain() -> ShopItem {
        ShopItem(
            id: id,
            name: name,
            calorie: calorie,
            protein: protein,
            fat: fat,
            carbohydrate: carbohydrate,
            type: type,
            photoData: nil,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted
        )
    }
}
