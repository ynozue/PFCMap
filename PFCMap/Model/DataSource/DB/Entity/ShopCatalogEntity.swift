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
    
    init(
        id: UUID,
        name: String,
        category: ShopCategory = .other,
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
            items: items.map { $0.toDomain() }
        )
    }
}
