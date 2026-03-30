import Foundation

public struct ShopItem: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let calorie: Double
    public let protein: Double
    public let fat: Double
    public let carbohydrate: Double
    public let photoData: Data?
    
    public nonisolated init(
        id: String = UUID().uuidString,
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
