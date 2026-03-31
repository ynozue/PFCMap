import Foundation
import SwiftData
import NZData

@Model
final class ShopItemEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var calorie: Double
    var protein: Double
    var fat: Double
    var carbohydrate: Double
    @Attribute(.externalStorage) var photoData: Data?
    
    init(
        id: UUID,
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

extension ShopItemEntity: DomainConvertibleModel {
    typealias Domain = ShopItem
    typealias PKey = UUID

    static func primaryKey(_ key: UUID) -> Predicate<ShopItemEntity> {
        return #Predicate<ShopItemEntity> { $0.id == key }
    }
    
    func toDomain() -> ShopItem {
        .init(
            id: id,
            name: name,
            calorie: calorie,
            protein: protein,
            fat: fat,
            carbohydrate: carbohydrate,
            photoData: photoData
        )
    }
}
