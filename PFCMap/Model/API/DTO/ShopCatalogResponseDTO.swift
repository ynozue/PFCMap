import Foundation

actor ShopCatalogResponseDTO: Decodable, Sendable {
    let catalogs: [ShopCatalogDTO]
    
    init(catalogs: [ShopCatalogDTO]) {
        self.catalogs = catalogs
    }
    
    enum CodingKeys: String, CodingKey {
        case catalogs = "shops"
    }
}

extension ShopCatalogResponseDTO {
    func toDomain() async -> [ShopCatalog] {
        var domainCatalogs: [ShopCatalog] = []
        for catalog in catalogs {
            domainCatalogs.append(await catalog.toDomain())
        }
        return domainCatalogs
    }
}
