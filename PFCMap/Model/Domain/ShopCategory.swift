import Foundation

public enum ShopCategory: String, Sendable, CaseIterable, Codable {
    case familyRestaurant = "ファミリーレストラン"
    case setMeal = "定食"
    case beefBowl = "牛丼・丼もの"
    case hamburger = "ハンバーガー"
    case sandwich = "サンドイッチ"
    case champon = "ちゃんぽん"
    case steak = "ステーキ"
    case udon = "うどん"
    case fastFood = "ファストフード"
    case curry = "カレー"
    case other = "その他"

    public var iconName: String {
        switch self {
        case .familyRestaurant: 
            return "fork.knife"
        case .setMeal, .beefBowl, .udon, .champon, .curry: 
            return "bowl.fill"
        case .hamburger, .sandwich, .fastFood: 
            return "takeoutbag.and.cup.and.card"
        case .steak: 
            return "flame.fill"
        case .other: 
            return "storefront.fill"
        }
    }
}
