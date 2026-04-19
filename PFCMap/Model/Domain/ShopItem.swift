import Foundation

struct ShopItem: Sendable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let calorie: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    let type: String
    let photoData: Data?
    let createdAt: Date
    let updatedAt: Date
    let deleted: Bool
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        calorie: Double,
        protein: Double,
        fat: Double,
        carbohydrate: Double,
        type: String = "",
        photoData: Data? = nil,
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
        self.photoData = photoData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}
