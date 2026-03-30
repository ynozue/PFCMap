import Foundation
import SwiftData
import NZData

@Model
public final class ShopCatalogEntity {
    @Attribute(.unique) public var id: String
    public var name: String
    public var category: String
    public var suitabilityMark: String
    public var descriptionText: String // descriptionはSwift標準にあるので避けるため
    @Relationship(deleteRule: .cascade) public var items: [ShopItemEntity]
    
    public init(
        id: String,
        name: String,
        category: String = "",
        suitabilityMark: String = "",
        descriptionText: String = "",
        items: [ShopItemEntity] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.suitabilityMark = suitabilityMark
        self.descriptionText = descriptionText
        self.items = items
    }
}

extension ShopCatalogEntity: DomainConvertibleModel {
    public typealias Domain = ShopCatalog
    public typealias PKey = String

    public static func primaryKey(_ key: String) -> Predicate<ShopCatalogEntity> {
        return #Predicate<ShopCatalogEntity> { $0.id == key }
    }
    
    public func toDomain() -> ShopCatalog {
        .init(
            id: id,
            name: name,
            category: category,
            suitabilityMark: suitabilityMark,
            description: descriptionText,
            items: items.map { $0.toDomain() }
        )
    }
}
