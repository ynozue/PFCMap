import Foundation
// import NZCore

public actor PFCRemoteClientImpl: PFCRemoteClient {
    public init() {}
    
    public func fetchShops() async throws -> [ShopCatalogResponseDTO] {
        // 本来は NZCore.remoteClient.fetch などを使って API 通信する
        // 現状はダミーを返す
        return [
            ShopCatalogResponseDTO(
                id: "shop-1",
                name: "すき家",
                items: [
                    ShopItemResponseDTO(id: "item-1-1", name: "牛丼 並盛", calorie: 733, protein: 22.9, fat: 25.0, carbohydrate: 104.1),
                    ShopItemResponseDTO(id: "item-1-2", name: "ねぎ玉牛丼 並盛", calorie: 835, protein: 27.6, fat: 31.8, carbohydrate: 106.3)
                ]
            ),
            ShopCatalogResponseDTO(
                id: "shop-2",
                name: "吉野家",
                items: [
                    ShopItemResponseDTO(id: "item-2-1", name: "牛丼 並盛", calorie: 635, protein: 20.2, fat: 25.9, carbohydrate: 79.7)
                ]
            )
        ]
    }
}
