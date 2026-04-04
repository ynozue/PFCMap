import Foundation

actor PFCRemoteClientDummy: PFCRemoteClient {
    init() {}
    
    func fetchShops(request: ShopCatalogRequestDTO) async throws -> ShopCatalogResponseDTO {
        await .init(catalogs: [
            .init(
                id: UUID(), name: "ガスト", category: "ファミリーレストラン",
                description: "低カロリーメニューが豊富で糖質0麺への変更も可能",
                items: [
                    .init(id: UUID(), name: "チーズINハンバーグ", calorie: 757, protein: 36.1, fat: 55.0, carbohydrate: 23.7),
                    .init(id: UUID(), name: "糖質0麺 ほうれん草の和風ジェノベーゼ", calorie: 218, protein: 5.2, fat: 12.1, carbohydrate: 2.4)
                ]
            ),
            .init(
                id: UUID(), name: "サイゼリヤ", category: "ファミリーレストラン",
                description: "若鶏のグリルやサラダなど高タンパク・低糖質な単品メニューが充実",
                items: [
                    .init(id: UUID(), name: "ミラノ風ドリア", calorie: 521, protein: 15.3, fat: 22.8, carbohydrate: 59.9),
                    .init(id: UUID(), name: "若鶏のディアボラ風", calorie: 390, protein: 31.0, fat: 17.7, carbohydrate: 6.0)
                ]
            ),
            .init(
                id: UUID(), name: "大戸屋", category: "定食",
                description: "栄養バランスに優れた和定食が多く五穀ごはんも選択できる",
                items: [
                    .init(id: UUID(), name: "しまほっけの炭火焼き定食", calorie: 588, protein: 45.0, fat: 20.0, carbohydrate: 55.0),
                    .init(id: UUID(), name: "鶏と野菜の黒酢あん定食", calorie: 979, protein: 31.5, fat: 36.5, carbohydrate: 124.7)
                ]
            ),
            .init(
                id: UUID(), name: "吉野家", category: "牛丼・丼もの",
                description: "ライザップ監修の低糖質・高タンパクな「牛サラダ」を提供",
                items: [
                    .init(id: UUID(), name: "ライザップ牛サラダ", calorie: 414, protein: 30.0, fat: 27.0, carbohydrate: 11.0),
                    .init(id: UUID(), name: "牛丼（並盛）", calorie: 635, protein: 19.3, fat: 23.3, carbohydrate: 84.7)
                ]
            ),
            .init(
                id: UUID(), name: "すき家", category: "牛丼・丼もの",
                description: "ご飯を豆腐と野菜に変えた「牛丼ライト」で糖質制限が可能",
                items: [
                    .init(id: UUID(), name: "牛丼ライト（並盛）", calorie: 425, protein: 19.8, fat: 28.1, carbohydrate: 15.7),
                    .init(id: UUID(), name: "牛丼（並盛）", calorie: 733, protein: 22.9, fat: 25.0, carbohydrate: 104.1)
                ]
            ),
            .init(
                id: UUID(), name: "松屋", category: "牛丼・丼もの",
                description: "定食のライスをサラダに変更できるセットなどの柔軟性がある",
                items: [
                    .init(id: UUID(), name: "牛めし（並盛）", calorie: 709, protein: 18.7, fat: 23.5, carbohydrate: 95.3),
                    .init(id: UUID(), name: "豚焼肉定食（ライスをサラダに変更）", calorie: 380, protein: 24.2, fat: 22.8, carbohydrate: 12.5)
                ]
            ),
            .init(
                id: UUID(), name: "モスバーガー", category: "ハンバーガー",
                description: "バンズをレタスに変更できる「菜摘」シリーズを展開",
                items: [
                    .init(id: UUID(), name: "モス野菜バーガー 菜摘", calorie: 206, protein: 9.8, fat: 12.5, carbohydrate: 11.9),
                    .init(id: UUID(), name: "モスバーガー", calorie: 367, protein: 12.6, fat: 17.5, carbohydrate: 39.5)
                ]
            ),
            .init(
                id: UUID(), name: "サブウェイ", category: "サンドイッチ",
                description: "野菜の増量が可能でパンやソースを細かくカスタマイズできる",
                items: [
                    .init(id: UUID(), name: "ローストチキン", calorie: 261, protein: 15.3, fat: 4.5, carbohydrate: 39.8),
                    .init(id: UUID(), name: "エビアボカド", calorie: 295, protein: 10.2, fat: 10.8, carbohydrate: 40.5)
                ]
            ),
            .init(
                id: UUID(), name: "フレッシュネスバーガー", category: "ハンバーガー",
                description: "低糖質バンズやソイパティを選択でき脂質も抑えられる",
                items: [
                    .init(id: UUID(), name: "ソイテリヤキバーガー（低糖質バンズ）", calorie: 280, protein: 14.5, fat: 12.2, carbohydrate: 25.5),
                    .init(id: UUID(), name: "クラシックチーズバーガー", calorie: 624, protein: 28.5, fat: 40.5, carbohydrate: 33.5)
                ]
            ),
            .init(
                id: UUID(), name: "やよい軒", category: "定食",
                description: "大豆ミートを使用した野菜炒め定食などのヘルシーな選択肢がある",
                items: [
                    .init(id: UUID(), name: "大豆ミートの野菜炒め定食", calorie: 420, protein: 25.0, fat: 15.0, carbohydrate: 45.0),
                    .init(id: UUID(), name: "しょうが焼定食", calorie: 654, protein: 32.5, fat: 28.5, carbohydrate: 65.5)
                ]
            ),
            .init(
                id: UUID(), name: "デニーズ", category: "ファミリーレストラン",
                description: "大豆ミートへの変更オプションがあり健康志向に対応",
                items: [
                    .init(id: UUID(), name: "大豆ミートのナポリタン", calorie: 480, protein: 18.0, fat: 12.0, carbohydrate: 75.0),
                    .init(id: UUID(), name: "和風ハンバーグ", calorie: 550, protein: 25.0, fat: 35.0, carbohydrate: 28.0)
                ]
            ),
            .init(
                id: UUID(), name: "リンガーハット", category: "ちゃんぽん",
                description: "豊富な国産野菜を一度に摂取でき栄養バランスが良い",
                items: [
                    .init(id: UUID(), name: "野菜たっぷりちゃんぽん", calorie: 831, protein: 29.5, fat: 33.5, carbohydrate: 95.5)
                ]
            ),
            .init(
                id: UUID(), name: "いきなり！ステーキ", category: "ステーキ",
                description: "赤身肉を単品で注文することで高タンパク・低糖質な食事が可能",
                items: [
                    .init(id: UUID(), name: "リブロースステーキ（300g）", calorie: 780, protein: 55.0, fat: 58.0, carbohydrate: 1.5)
                ]
            ),
            .init(
                id: UUID(), name: "丸亀製麺", category: "うどん",
                description: "野菜天ぷらやおでんなどの組み合わせで調整が可能",
                items: [
                    .init(id: UUID(), name: "かけうどん（並）", calorie: 299, protein: 9.8, fat: 1.2, carbohydrate: 61.5),
                    .init(id: UUID(), name: "野菜かき揚げ", calorie: 459, protein: 3.5, fat: 35.0, carbohydrate: 32.0)
                ]
            ),
            .init(
                id: UUID(), name: "マクドナルド", category: "ハンバーガー",
                description: "揚げ物やパンが多く高カロリーになりやすいがサイドサラダ等で調整可能",
                items: [
                    .init(id: UUID(), name: "ビッグマック", calorie: 525, protein: 26.0, fat: 28.3, carbohydrate: 41.8),
                    .init(id: UUID(), name: "サイドサラダ", calorie: 10, protein: 0.5, fat: 0.1, carbohydrate: 2.2)
                ]
            ),
            .init(
                id: UUID(), name: "ケンタッキー", category: "ファストフード",
                description: "揚げ物が中心で脂質と塩分が高い傾向",
                items: [
                    .init(id: UUID(), name: "オリジナルチキン", calorie: 237, protein: 18.3, fat: 14.7, carbohydrate: 7.9),
                    .init(id: UUID(), name: "コールスロー（M）", calorie: 154, protein: 1.3, fat: 11.5, carbohydrate: 11.5)
                ]
            ),
            .init(
                id: UUID(), name: "CoCo壱番屋", category: "カレー",
                description: "ライスの量が多く糖質過多になりやすい",
                items: [
                    .init(id: UUID(), name: "ポークカレー（ライス300g）", calorie: 748, protein: 9.5, fat: 28.5, carbohydrate: 110.5),
                    .init(id: UUID(), name: "低糖質カリフラワーライス カレー", calorie: 285, protein: 8.5, fat: 15.0, carbohydrate: 18.5),
                    .init(id: UUID(), name: "削除済みアイテム", calorie: 0, protein: 0, fat: 0, carbohydrate: 0, deleted: true)
                ]
            ),
            .init(
                id: UUID(), name: "削除済みショップ", category: "テスト",
                description: "非表示になるはずのショップ",
                items: [
                    .init(id: UUID(), name: "アイテム", calorie: 100, protein: 10, fat: 10, carbohydrate: 10)
                ],
                deleted: true
            )
        ])
    }
}
