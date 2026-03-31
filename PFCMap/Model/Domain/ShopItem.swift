import Foundation

struct ShopItem: Sendable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let calorie: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    let photoData: Data?
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        calorie: Double,
        protein: Double,
        fat: Double,
        carbohydrate: Double,
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.calorie = calorie
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
        self.photoData = photoData
    }
}
