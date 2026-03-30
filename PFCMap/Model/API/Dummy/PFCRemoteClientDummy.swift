import Foundation

public actor PFCRemoteClientDummy: PFCRemoteClient {
    public init() {}
    
    public func fetchShops() async throws -> [ShopCatalogResponseDTO] {
        return [
            .init(
                id: "1", name: "ガスト", category: "ファミリーレストラン", suitabilityMark: "○",
                description: "低カロリーメニューが豊富で糖質0麺への変更も可能",
                items: [
                    .init(id: "101", name: "チーズINハンバーグ", calorie: 757, protein: 36.1, fat: 55.0, carbohydrate: 23.7),
                    .init(id: "102", name: "糖質0麺 ほうれん草の和風ジェノベーゼ", calorie: 218, protein: 5.2, fat: 12.1, carbohydrate: 2.4)
                ]
            ),
            .init(
                id: "2", name: "サイゼリヤ", category: "ファミリーレストラン", suitabilityMark: "○",
                description: "若鶏のグリルやサラダなど高タンパク・低糖質な単品メニューが充実",
                items: [
                    .init(id: "201", name: "ミラノ風ドリア", calorie: 521, protein: 15.3, fat: 22.8, carbohydrate: 59.9),
                    .init(id: "202", name: "若鶏のディアボラ風", calorie: 390, protein: 31.0, fat: 17.7, carbohydrate: 6.0),
                    .init(id: "203", name: "小エビのサラダ", calorie: 190, protein: 11.3, fat: 13.8, carbohydrate: 4.9)
                ]
            ),
            .init(
                id: "3", name: "大戸屋", category: "定食", suitabilityMark: "○",
                description: "栄養バランスに優れた和定食が多く五穀ごはんも選択できる",
                items: [
                    .init(id: "301", name: "しまほっけの炭火焼き定食", calorie: 588, protein: 45.0, fat: 20.0, carbohydrate: 55.0),
                    .init(id: "302", name: "鶏と野菜の黒酢あん定食", calorie: 979, protein: 31.5, fat: 36.5, carbohydrate: 124.7)
                ]
            ),
            .init(
                id: "4", name: "吉野家", category: "牛丼・丼もの", suitabilityMark: "○",
                description: "ライザップ監修の低糖質・高タンパクな「牛サラダ」を提供",
                items: [
                    .init(id: "401", name: "ライザップ牛サラダ", calorie: 414, protein: 30.0, fat: 27.0, carbohydrate: 11.0),
                    .init(id: "402", name: "牛丼（並盛）", calorie: 635, protein: 19.3, fat: 23.3, carbohydrate: 84.7)
                ]
            ),
            .init(
                id: "5", name: "すき家", category: "牛丼・丼もの", suitabilityMark: "○",
                description: "ご飯を豆腐と野菜に変えた「牛丼ライト」で糖質制限が可能",
                items: [
                    .init(id: "501", name: "牛丼ライト（並盛）", calorie: 425, protein: 19.8, fat: 28.1, carbohydrate: 15.7),
                    .init(id: "502", name: "牛丼（並盛）", calorie: 733, protein: 22.9, fat: 25.0, carbohydrate: 104.1)
                ]
            ),
            .init(
                id: "6", name: "松屋", category: "牛丼・丼もの", suitabilityMark: "○",
                description: "定食のライスをサラダに変更できるセットなどの柔軟性がある",
                items: [
                    .init(id: "601", name: "牛めし（並盛）", calorie: 709, protein: 18.7, fat: 23.5, carbohydrate: 95.3),
                    .init(id: "602", name: "豚焼肉定食（ライスをサラダに変更）", calorie: 380, protein: 24.2, fat: 22.8, carbohydrate: 12.5)
                ]
            ),
            .init(
                id: "7", name: "モスバーガー", category: "ハンバーガー", suitabilityMark: "○",
                description: "バンズをレタスに変更できる「菜摘」シリーズを展開",
                items: [
                    .init(id: "701", name: "モス野菜バーガー 菜摘", calorie: 206, protein: 9.8, fat: 12.5, carbohydrate: 11.9),
                    .init(id: "702", name: "モスバーガー", calorie: 367, protein: 12.6, fat: 17.5, carbohydrate: 39.5)
                ]
            ),
            .init(
                id: "8", name: "サブウェイ", category: "サンドイッチ", suitabilityMark: "○",
                description: "野菜の増量が可能でパンやソースを細かくカスタマイズできる",
                items: [
                    .init(id: "801", name: "ローストチキン", calorie: 261, protein: 15.3, fat: 4.5, carbohydrate: 39.8),
                    .init(id: "802", name: "エビアボカド", calorie: 295, protein: 10.2, fat: 10.8, carbohydrate: 40.5)
                ]
            ),
            .init(
                id: "9", name: "フレッシュネスバーガー", category: "ハンバーガー", suitabilityMark: "○",
                description: "低糖質バンズやソイパティを選択でき脂質も抑えられる",
                items: [
                    .init(id: "901", name: "ソイテリヤキバーガー（低糖質バンズ）", calorie: 280, protein: 14.5, fat: 12.2, carbohydrate: 25.5),
                    .init(id: "902", name: "クラシックチーズバーガー", calorie: 624, protein: 28.5, fat: 40.5, carbohydrate: 33.5)
                ]
            ),
            .init(
                id: "10", name: "やよい軒", category: "定食", suitabilityMark: "○",
                description: "大豆ミートを使用した野菜炒め定食などのヘルシーな選択肢がある",
                items: [
                    .init(id: "1001", name: "大豆ミートの野菜炒め定食", calorie: 420, protein: 25.0, fat: 15.0, carbohydrate: 45.0),
                    .init(id: "1002", name: "しょうが焼定食", calorie: 654, protein: 32.5, fat: 28.5, carbohydrate: 65.5)
                ]
            ),
            .init(
                id: "11", name: "ロイヤルホスト", category: "ファミリーレストラン", suitabilityMark: "○",
                description: "満足感のあるチキンサラダなどの主食級サラダメニューが充実",
                items: [
                    .init(id: "1101", name: "食いしんぼうのシェフサラダ", calorie: 450, protein: 18.0, fat: 35.0, carbohydrate: 12.0),
                    .init(id: "1102", name: "黒×黒ハンバーグ", calorie: 850, protein: 42.0, fat: 55.0, carbohydrate: 35.0)
                ]
            ),
            .init(
                id: "12", name: "デニーズ", category: "ファミリーレストラン", suitabilityMark: "○",
                description: "大豆ミートへの変更オプションがあり健康志向に対応",
                items: [
                    .init(id: "1201", name: "大豆ミートのナポリタン", calorie: 480, protein: 18.0, fat: 12.0, carbohydrate: 75.0),
                    .init(id: "1202", name: "和風ハンバーグ", calorie: 550, protein: 25.0, fat: 35.0, carbohydrate: 28.0)
                ]
            ),
            .init(
                id: "13", name: "スシロー", category: "寿司", suitabilityMark: "○",
                description: "シャリを半分にする設定が可能で高タンパクな魚介類を選べる",
                items: [
                    .init(id: "1301", name: "まぐろ（シャリ半分）", calorie: 60, protein: 5.0, fat: 0.5, carbohydrate: 8.0),
                    .init(id: "1302", name: "寒ぶり", calorie: 120, protein: 4.5, fat: 7.0, carbohydrate: 9.0)
                ]
            ),
            .init(
                id: "14", name: "くら寿司", category: "寿司", suitabilityMark: "○",
                description: "「シャリ野菜」や「シャリプチ」など独自の糖質オフメニューがある",
                items: [
                    .init(id: "1401", name: "シャリ野菜 びんちょう赤身", calorie: 32, protein: 3.5, fat: 0.2, carbohydrate: 4.5),
                    .init(id: "1402", name: "極み熟成 まぐろ", calorie: 88, protein: 4.5, fat: 0.3, carbohydrate: 16.5)
                ]
            ),
            .init(
                id: "15", name: "はま寿司", category: "寿司", suitabilityMark: "○",
                description: "シャリ少なめ対応があり摂取する糖質量を調整しやすい",
                items: [
                    .init(id: "1501", name: "活〆ぶり（シャリ少なめ）", calorie: 95, protein: 4.5, fat: 6.5, carbohydrate: 4.5),
                    .init(id: "1502", name: "厳選まぐろ", calorie: 80, protein: 4.8, fat: 0.2, carbohydrate: 14.5)
                ]
            ),
            .init(
                id: "16", name: "しゃぶ葉", category: "しゃぶしゃぶ", suitabilityMark: "○",
                description: "茹でる調理で余分な脂が落ち野菜も大量に摂取できる",
                items: [
                    .init(id: "1601", name: "牛＆豚しゃぶしゃぶ食べ放題（標準摂取目安）", calorie: 650, protein: 45.0, fat: 40.0, carbohydrate: 20.0)
                ]
            ),
            .init(
                id: "17", name: "焼肉きんぐ", category: "焼肉", suitabilityMark: "○",
                description: "赤身肉やラム肉・海鮮など低脂質なタンパク質源を選択可能",
                items: [
                    .init(id: "1701", name: "きんぐコース（赤身肉中心目安）", calorie: 850, protein: 65.0, fat: 55.0, carbohydrate: 15.0)
                ]
            ),
            .init(
                id: "18", name: "リンガーハット", category: "ちゃんぽん", suitabilityMark: "○",
                description: "豊富な国産野菜を一度に摂取でき栄養バランスが良い",
                items: [
                    .init(id: "1801", name: "野菜たっぷりちゃんぽん", calorie: 831, protein: 29.5, fat: 33.5, carbohydrate: 95.5)
                ]
            ),
            .init(
                id: "19", name: "いきなり！ステーキ", category: "ステーキ", suitabilityMark: "○",
                description: "赤身肉を単品で注文することで高タンパク・低糖質な食事が可能",
                items: [
                    .init(id: "1901", name: "リブロースステーキ（300g）", calorie: 780, protein: 55.0, fat: 58.0, carbohydrate: 1.5)
                ]
            ),
            .init(
                id: "20", name: "丸亀製麺", category: "うどん", suitabilityMark: "○",
                description: "野菜天ぷらやおでんなどの組み合わせで調整が可能",
                items: [
                    .init(id: "2001", name: "かけうどん（並）", calorie: 299, protein: 9.8, fat: 1.2, carbohydrate: 61.5),
                    .init(id: "2002", name: "野菜かき揚げ", calorie: 459, protein: 3.5, fat: 35.0, carbohydrate: 32.0)
                ]
            ),
            .init(
                id: "21", name: "マクドナルド", category: "ハンバーガー", suitabilityMark: "-",
                description: "揚げ物やパンが多く高カロリーになりやすいがサイドサラダ等で調整可能",
                items: [
                    .init(id: "2101", name: "ビッグマック", calorie: 525, protein: 26.0, fat: 28.3, carbohydrate: 41.8),
                    .init(id: "2102", name: "サイドサラダ", calorie: 10, protein: 0.5, fat: 0.1, carbohydrate: 2.2)
                ]
            ),
            .init(
                id: "22", name: "ケンタッキー", category: "ファストフード", suitabilityMark: "-",
                description: "揚げ物が中心で脂質と塩分が高い傾向",
                items: [
                    .init(id: "2201", name: "オリジナルチキン", calorie: 237, protein: 18.3, fat: 14.7, carbohydrate: 7.9),
                    .init(id: "2202", name: "コールスロー（M）", calorie: 154, protein: 1.3, fat: 11.5, carbohydrate: 11.5)
                ]
            ),
            .init(
                id: "23", name: "餃子の王将", category: "中華", suitabilityMark: "-",
                description: "炭水化物と脂質の割合が高いがメニューの選び方次第で対応可能",
                items: [
                    .init(id: "2301", name: "餃子（1枚6個）", calorie: 346, protein: 10.5, fat: 18.5, carbohydrate: 32.5),
                    .init(id: "2302", name: "野菜炒め", calorie: 450, protein: 15.0, fat: 35.0, carbohydrate: 12.0)
                ]
            ),
            .init(
                id: "24", name: "CoCo壱番屋", category: "カレー", suitabilityMark: "-",
                description: "ライスの量が多く糖質過多になりやすい",
                items: [
                    .init(id: "2401", name: "ポークカレー（ライス300g）", calorie: 748, protein: 9.5, fat: 28.5, carbohydrate: 110.5),
                    .init(id: "2402", name: "低糖質カリフラワーライス カレー", calorie: 285, protein: 8.5, fat: 15.0, carbohydrate: 18.5)
                ]
            )
        ]
    }
}
