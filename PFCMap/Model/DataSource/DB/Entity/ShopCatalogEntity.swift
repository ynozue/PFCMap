import Foundation
import SwiftData
import NZData

@Model
public final class ShopCatalogEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var category: String
    public var descriptionText: String // descriptionはSwift標準にあるので避けるため
    @Relationship(deleteRule: .cascade) public var items: [ShopItemEntity]
    
    public init(
        id: UUID,
        name: String,
        category: String = "",
        descriptionText: String = "",
        items: [ShopItemEntity] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.descriptionText = descriptionText
        self.items = items
    }
}

extension ShopCatalogEntity: DomainConvertibleModel {
    public typealias Domain = ShopCatalog
    public typealias PKey = UUID

    public static func primaryKey(_ key: UUID) -> Predicate<ShopCatalogEntity> {
        return #Predicate<ShopCatalogEntity> { $0.id == key }
    }
    
    public func toDomain() -> ShopCatalog {
        .init(
            id: id,
            name: name,
            category: category,
            description: descriptionText,
            items: items.map { $0.toDomain() }
        )
    }
}
