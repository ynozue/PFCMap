import Foundation
import SwiftData
import NZData

@Model
final class ShopItemEntity {
    #Index<ShopItemEntity>([\.calorie], [\.protein], [\.fat], [\.carbohydrate])

    @Attribute(.unique) var id: UUID
    var name: String
    var calorie: Double
    var protein: Double
    var fat: Double
    var carbohydrate: Double
    var type: String
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date
    var updatedAt: Date
    var deleted: Bool
    
    init(
        id: UUID,
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
            type: type,
            photoData: photoData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted
        )
    }
}
