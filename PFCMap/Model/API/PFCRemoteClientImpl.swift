import Foundation
// import NZCore

actor PFCRemoteClientImpl: PFCRemoteClient {
    init() {}
    
    func fetchShops(request: ShopCatalogRequestDTO) async throws -> ShopCatalogResponseDTO {
        // 本来は NZCore.remoteClient.fetch などを使って API 通信する
        // 現状はダミーを返す
        await ShopCatalogResponseDTO(
            catalogs: [
                ShopCatalogDTO(
                    id: UUID(),
                    name: "すき家",
                    items: [
                        ShopItemDTO(id: UUID(), name: "牛丼 並盛", calorie: 733, protein: 22.9, fat: 25.0, carbohydrate: 104.1),
                        ShopItemDTO(id: UUID(), name: "ねぎ玉牛丼 並盛", calorie: 835, protein: 27.6, fat: 31.8, carbohydrate: 106.3)
                    ]
                ),
                ShopCatalogDTO(
                    id: UUID(),
                    name: "吉野家",
                    items: [
                        ShopItemDTO(id: UUID(), name: "牛丼 並盛", calorie: 635, protein: 20.2, fat: 25.9, carbohydrate: 79.7)
                    ]
                )
            ]
        )
    }
}
