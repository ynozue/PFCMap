import Foundation

public actor PFCRemoteClientDummy: PFCRemoteClient {
    public init() {}
    
    public func fetchShops() async throws -> [ShopResponseDTO] {
        return [
            .init(
                id: "1",
                name: "すき家",
                menus: [
                    .init(id: "101", name: "牛丼（並）", calorie: 733, protein: 22.9, fat: 25.0, carbohydrate: 104.1),
                    .init(id: "102", name: "まぐろたたき丼", calorie: 611, protein: 25.9, fat: 12.0, carbohydrate: 100.0)
                ]
            ),
            .init(
                id: "2",
                name: "サイゼリヤ",
                menus: [
                    .init(id: "201", name: "ミラノ風ドリア", calorie: 521, protein: 17.1, fat: 27.6, carbohydrate: 51.1),
                    .init(id: "202", name: "小エビのサラダ", calorie: 115, protein: 5.4, fat: 8.3, carbohydrate: 4.8)
                ]
            )
        ]
    }
}
