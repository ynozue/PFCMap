import SwiftUI
import NZData

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
    var isExpanded: Bool = true

    struct DisplayItem: Identifiable, Equatable {
        var id: String { "\(shop.id.uuidString)-\(item.id.uuidString)" }
        let shop: ShopCatalog
        let item: ShopItem
    }
    
    func displayItems(
        from shops: [ShopCatalog],
        proteinThreshold: ProteinThreshold,
        fatThreshold: FatThreshold,
        disabledShopIds: Set<UUID>,
        currentLocation: Location?,
        searchResults: [ShopSearchResult],
        mapDistance: Int
    ) -> [DisplayItem] {
        var items = shops
            .filter { shop in
                // 非表示店舗
                guard !disabledShopIds.contains(shop.id) else { return false }
                
                // 指定された円（mapDistance）の中に店舗があるかチェック
                if let currentLocation {
                    return searchResults.contains { result in
                        result.query == shop.name &&
                        result.location.distance(to: currentLocation) <= Double(mapDistance)
                    }
                }
                return true
            }
            .flatMap { shop in
                shop.items.compactMap { item -> DisplayItem? in
                    // pが閾値以上
                    guard item.protein >= Double(proteinThreshold.rawValue) else { return nil }
                    // fが閾値以下
                    guard item.fat <= Double(fatThreshold.rawValue) else { return nil }
                    
                    return DisplayItem(shop: shop, item: item)
                }
            }
        
        switch sortType {
        case .calorie:
            items.sort { $0.item.calorie < $1.item.calorie }
        case .protein:
            items.sort { $0.item.protein > $1.item.protein }
        case .fat:
            items.sort { $0.item.fat < $1.item.fat }
        case .carbohydrate:
            items.sort { $0.item.carbohydrate < $1.item.carbohydrate }
        }
        
        return items
    }
}


