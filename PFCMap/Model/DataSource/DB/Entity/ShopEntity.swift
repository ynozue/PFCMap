import Foundation
import SwiftData
import NZData

@Model
public final class ShopEntity {
    @Attribute(.unique) public var id: String
    public var name: String
    @Relationship(deleteRule: .cascade) public var menus: [MenuEntity]
    
    public init(id: String, name: String, menus: [MenuEntity] = []) {
        self.id = id
        self.name = name
        self.menus = menus
    }
}

extension ShopEntity: DomainConvertibleModel {
    public typealias Domain = Shop
    public typealias PKey = String

    public static func primaryKey(_ key: String) -> Predicate<ShopEntity> {
        return #Predicate<ShopEntity> { $0.id == key }
    }
    
    public func toDomain() -> Shop {
        .init(
            id: id,
            name: name,
            menus: menus.map { $0.toDomain() }
        )
    }
}
