import Foundation
import SwiftData
import NZData

@Model
public final class ShopItemEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var calorie: Double
    public var protein: Double
    public var fat: Double
    public var carbohydrate: Double
    @Attribute(.externalStorage) public var photoData: Data?
    
    public init(
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
    public typealias Domain = ShopItem
    public typealias PKey = UUID

    public static func primaryKey(_ key: UUID) -> Predicate<ShopItemEntity> {
        return #Predicate<ShopItemEntity> { $0.id == key }
    }
    
    public func toDomain() -> ShopItem {
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
