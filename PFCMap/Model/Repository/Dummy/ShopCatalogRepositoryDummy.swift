import Foundation

public actor ShopCatalogRepositoryDummy: ShopCatalogRepository {
    private let shops: [ShopCatalog] = [
        ShopCatalog(name: "ガスト", items: [
            ShopItem(name: "若鶏のグリル (1枚)", calorie: 395, protein: 25.1, fat: 31.8, carbohydrate: 2.1),
            ShopItem(name: "糖質0麺 ほうれん草の和風ジェノベーゼ", calorie: 218, protein: 5.2, fat: 12.1, carbohydrate: 2.4)
        ]),
        ShopCatalog(name: "サイゼリヤ", items: [
            ShopItem(name: "若鶏のディアボラ風", calorie: 541, protein: 29.8, fat: 43.1, carbohydrate: 6.8),
            ShopItem(name: "小エビのサラダ", calorie: 127, protein: 5.4, fat: 9.1, carbohydrate: 5.9),
            ShopItem(name: "辛味チキン (5本)", calorie: 295, protein: 17.5, fat: 21.3, carbohydrate: 8.2)
        ]),
        ShopCatalog(name: "大戸屋", items: [
            ShopItem(name: "しまほっけの炭火焼き定食 (おかずのみ)", calorie: 375, protein: 52.8, fat: 16.5, carbohydrate: 1.2),
            ShopItem(name: "鶏と野菜の黒酢あん定食 (おかずのみ)", calorie: 528, protein: 18.2, fat: 28.5, carbohydrate: 48.6)
        ]),
        ShopCatalog(name: "吉野家", items: [
            ShopItem(name: "ライザップ牛サラダ", calorie: 414, protein: 30.0, fat: 27.0, carbohydrate: 11.0),
            ShopItem(name: "牛丼 (並盛)", calorie: 635, protein: 19.3, fat: 23.3, carbohydrate: 84.7)
        ]),
        ShopCatalog(name: "すき家", items: [
            ShopItem(name: "牛丼ライト (お肉並盛)", calorie: 425, protein: 19.8, fat: 28.1, carbohydrate: 15.7),
            ShopItem(name: "ほろほろチキンカレー", calorie: 953, protein: 39.5, fat: 30.1, carbohydrate: 130.2)
        ]),
        ShopCatalog(name: "松屋", items: [
            ShopItem(name: "牛めし (並盛)", calorie: 709, protein: 18.7, fat: 23.5, carbohydrate: 95.3),
            ShopItem(name: "牛焼肉定食 (ライスをサラダに変更)", calorie: 380, protein: 24.2, fat: 22.8, carbohydrate: 12.5)
        ]),
        ShopCatalog(name: "モスバーガー", items: [
            ShopItem(name: "モス野菜 バーガー 菜摘", calorie: 206, protein: 9.8, fat: 12.5, carbohydrate: 11.9),
            ShopItem(name: "テリヤキチキン 菜摘", calorie: 188, protein: 15.1, fat: 10.2, carbohydrate: 8.5)
        ]),
        ShopCatalog(name: "サブウェイ", items: [
            ShopItem(name: "ローストチキン", calorie: 261, protein: 15.3, fat: 4.5, carbohydrate: 39.8),
            ShopItem(name: "エビアボカド", calorie: 295, protein: 10.2, fat: 10.8, carbohydrate: 40.5)
        ]),
        ShopCatalog(name: "フレッシュネスバーガー", items: [
            ShopItem(name: "ガーデンサラダバーガー (低糖質バンズ)", calorie: 305, protein: 12.1, fat: 18.5, carbohydrate: 20.2),
            ShopItem(name: "ソイテリヤキバーガー (低糖質バンズ)", calorie: 280, protein: 14.5, fat: 12.2, carbohydrate: 25.5)
        ])
    ]
    
    public init() {}

    
    public func sync() async throws {
        // Dummy implementation for sync
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    public func fetchShops() async throws -> [ShopCatalog] {
        shops
    }
    
    public func addShop(_ shop: ShopCatalog) async throws {
    }
    
    public func saveShops(_ shops: [ShopCatalog]) async throws {
    }
    
    public func clearAll() async throws {
    }
}
