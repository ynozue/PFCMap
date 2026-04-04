import Foundation
import SwiftData
import NZData

@Model
final class ShopCatalogEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: ShopCategory
    var descriptionText: String // descriptionはSwift標準にあるので避けるため
    @Relationship(deleteRule: .cascade) var items: [ShopItemEntity]
    var createdAt: Date
    var updatedAt: Date
    var deleted: Bool
    
    init(
        id: UUID,
        name: String,
        category: ShopCategory = .other,
        descriptionText: String = "",
        items: [ShopItemEntity] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.descriptionText = descriptionText
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

extension ShopCatalogEntity: DomainConvertibleModel {
    typealias Domain = ShopCatalog
    typealias PKey = UUID

    static func primaryKey(_ key: UUID) -> Predicate<ShopCatalogEntity> {
        return #Predicate<ShopCatalogEntity> { $0.id == key }
    }
    
    func toDomain() -> ShopCatalog {
        .init(
            id: id,
            name: name,
            category: category,
            description: descriptionText,
            items: items.map { $0.toDomain() },
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted
        )
    }
}
