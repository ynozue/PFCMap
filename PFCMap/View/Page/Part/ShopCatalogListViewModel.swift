import SwiftUI

@MainActor
@Observable
class ShopCatalogListViewModel {
    enum SortType: String, CaseIterable {
        case calorie = "カロリー"
        case protein = "タンパク質"
        case fat = "脂質"
        case carbohydrate = "炭水化物"
    }
    
    var sortType: SortType = .calorie
    var isProteinFilterEnabled: Bool = false
    var isFatFilterEnabled: Bool = false
    var isExpanded: Bool = true

    struct DisplayItem: Identifiable, Equatable {
        var id: String { "\(shop.id.uuidString)-\(item.id.uuidString)" }
        let shop: ShopCatalog
        let item: ShopItem
    }
    
    func displayItems(from shops: [ShopCatalog], proteinThreshold: Int, fatThreshold: Int) -> [DisplayItem] {
        var items = shops.flatMap { shop in
            shop.items.compactMap { item -> DisplayItem? in
                if isProteinFilterEnabled {
                    // pが閾値以上
                    guard item.protein >= Double(proteinThreshold) else { return nil }
                }
                if isFatFilterEnabled {
                    // fが閾値以下
                    guard item.fat <= Double(fatThreshold) else { return nil }
                }
                return DisplayItem(shop: shop, item: item)
            }
        }
        
        switch sortType {
        case .calorie:
            items.sort { $0.item.calorie < $1.item.calorie }
        case .protein:
            items.sort { $0.item.protein > $1.item.protein } // protein is usually "more is better" but calorie is "less is better"?
        case .fat:
            items.sort { $0.item.fat < $1.item.fat }
        case .carbohydrate:
            items.sort { $0.item.carbohydrate < $1.item.carbohydrate }
        }
        
        return items
    }
}


