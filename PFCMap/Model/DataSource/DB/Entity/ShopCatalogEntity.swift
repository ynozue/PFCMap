import Foundation
import SwiftData
import NZData

@Model
public final class ShopCatalogEntity {
    @Attribute(.unique) public var id: String
    public var name: String
    @Relationship(deleteRule: .cascade) public var items: [ShopItemEntity]
    
    public init(id: String, name: String, items: [ShopItemEntity] = []) {
        self.id = id
        self.name = name
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
            items: items.map { $0.toDomain() }
        )
    }
}
