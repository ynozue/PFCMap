import Foundation

public actor ShopCatalogRepositoryDummy: ShopCatalogRepository {
    private let shops: [ShopCatalog] = [
        ShopCatalog(
            name: "ガスト", category: "ファミリーレストラン",
            description: "低カロリーメニューが豊富で糖質0麺への変更も可能",
            items: [
                ShopItem(name: "チーズINハンバーグ", calorie: 757, protein: 36.1, fat: 55.0, carbohydrate: 23.7),
                ShopItem(name: "糖質0麺 ほうれん草의 和風ジェノベーゼ", calorie: 218, protein: 5.2, fat: 12.1, carbohydrate: 2.4)
            ]
        ),
        ShopCatalog(
            name: "サイゼリヤ", category: "ファミリーレストラン",
            description: "若鶏のグリルやサラダなど高タンパク・低糖質な単品メニューが充実",
            items: [
                ShopItem(name: "ミラノ風ドリア", calorie: 521, protein: 15.3, fat: 22.8, carbohydrate: 59.9),
                ShopItem(name: "若鶏のディアボラ風", calorie: 390, protein: 31.0, fat: 17.7, carbohydrate: 6.0)
            ]
        ),
        ShopCatalog(
            name: "大戸屋", category: "定食",
            description: "栄養バランスに優れた和定食が多く五穀ごはんも選択できる",
            items: [
                ShopItem(name: "しまほっけの炭火焼き定食", calorie: 588, protein: 45.0, fat: 20.0, carbohydrate: 55.0)
            ]
        ),
        ShopCatalog(
            name: "吉野家", category: "牛丼・丼もの",
            description: "ライザップ監修の低糖質・高タンパクな「牛サラダ」を提供",
            items: [
                ShopItem(name: "ライザップ牛サラダ", calorie: 414, protein: 30.0, fat: 27.0, carbohydrate: 11.0)
            ]
        ),
        ShopCatalog(
            name: "マクドナルド", category: "ハンバーガー",
            description: "揚げ物やパンが多く高カロリーになりやすいがサイドサラダ等で調整可能",
            items: [
                ShopItem(name: "ビッグマック", calorie: 525, protein: 26.0, fat: 28.3, carbohydrate: 41.8)
            ]
        )
    ]
    
    public init() {}

    public func sync() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    public func fetchShops() async throws -> [ShopCatalog] {
        shops
    }
    
    public func addShop(_ shop: ShopCatalog) async throws {}
    public func saveShops(_ shops: [ShopCatalog]) async throws {}
    public func clearAll() async throws {}
}
