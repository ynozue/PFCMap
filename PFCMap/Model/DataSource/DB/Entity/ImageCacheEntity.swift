import Foundation
import SwiftData
import NZData

@Model
final class ImageCacheEntity {
    @Attribute(.unique) var url: String
    @Attribute(.externalStorage) var data: Data
    var updatedAt: Date
    
    init(url: String, data: Data, updatedAt: Date = Date()) {
        self.url = url
        self.data = data
        self.updatedAt = updatedAt
    }
}

extension ImageCacheEntity: DomainConvertibleModel {
    typealias Domain = ImageCache
    typealias PKey = String

    static func primaryKey(_ key: String) -> Predicate<ImageCacheEntity> {
        return #Predicate<ImageCacheEntity> { $0.url == key }
    }
    
    func toDomain() -> ImageCache {
        .init(
            url: url,
            data: data,
            updatedAt: updatedAt
        )
    }
}
