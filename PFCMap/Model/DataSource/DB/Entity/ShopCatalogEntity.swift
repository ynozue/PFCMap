import Foundation
import SwiftData
import NZData

@Model
final class ShopCatalogEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: ShopCategory
    var descriptionText: String // descriptionはSwift標準にあるので避けるため
    var type: Int
    @Relationship(deleteRule: .cascade) var items: [ShopItemEntity]
    var createdAt: Date
    var updatedAt: Date
    // 注意: "deleted" は Core Data の予約名 (NSManagedObject.isDeleted) と衝突し
    // save 後に常に false を返すようになるため、プロパティ名を変えて列名だけ維持する
    @Attribute(originalName: "deleted") var isRemoved: Bool

    init(
        id: UUID,
        name: String,
        category: ShopCategory = .other,
        descriptionText: String = "",
        type: Int = 0,
        items: [ShopItemEntity] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.descriptionText = descriptionText
        self.type = type
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isRemoved = deleted
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
            type: type,
            items: items.map { $0.toDomain() },
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: isRemoved
        )
    }
}
