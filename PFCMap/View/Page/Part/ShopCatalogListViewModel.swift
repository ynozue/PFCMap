import SwiftUI
import Observation
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
    var selectedShopId: UUID? = nil

    struct DisplayItem: Identifiable, Equatable {
        var id: String { "\(shop.id.uuidString)-\(item.id.uuidString)" }
        let shop: ShopCatalog
        let item: ShopItem
    }
    
    struct TabItem: Identifiable, Equatable {
        let id: UUID? // nil for ALL
        let name: String
        let count: Int
    }
    
    func inRangeShops(
        from shops: [ShopCatalog],
        disabledShopIds: Set<UUID>,
        currentLocation: Location?,
        searchResults: [ShopSearchResult],
        mapDistance: Int
    ) -> [ShopCatalog] {
        shops.filter { shop in
            // 非表示店舗
            guard !disabledShopIds.contains(shop.id) else { return false }
            
            // 主食メニューがあるか
            guard shop.items.contains(where: { $0.type == "主食" }) else { return false }
            
            // 指定された円（mapDistance）の中に店舗があるかチェック
            if let currentLocation {
                return searchResults.contains { result in
                    result.query == shop.name &&
                    result.location.distance(to: currentLocation) <= Double(mapDistance)
                }
            }
            return true
        }
    }
    
    func tabItems(
        from shops: [ShopCatalog],
        proteinThreshold: ProteinThreshold,
        fatThreshold: FatThreshold,
        disabledShopIds: Set<UUID>,
        currentLocation: Location?,
        searchResults: [ShopSearchResult],
        mapDistance: Int
    ) -> [TabItem] {
        let inRange = inRangeShops(
            from: shops,
            disabledShopIds: disabledShopIds,
            currentLocation: currentLocation,
            searchResults: searchResults,
            mapDistance: mapDistance
        )
        
        var tabs: [TabItem] = []
        
        // Calculate ALL count
        var allCount = 0
        for shop in inRange {
            let shopItemCount = shop.items.filter { item in
                item.type == "主食" &&
                item.protein >= Double(proteinThreshold.rawValue) &&
                item.fat <= Double(fatThreshold.rawValue)
            }.count
            
            if shopItemCount > 0 {
                tabs.append(TabItem(id: shop.id, name: shop.name, count: shopItemCount))
                allCount += shopItemCount
            }
        }
        
        // Add ALL at the beginning
        if allCount > 0 {
            tabs.insert(TabItem(id: nil, name: "ALL", count: allCount), at: 0)
        }
        
        return tabs
    }
    
    
    func displayItemsForTab(
        tab: TabItem,
        from shops: [ShopCatalog],
        proteinThreshold: ProteinThreshold,
        fatThreshold: FatThreshold,
        disabledShopIds: Set<UUID>,
        currentLocation: Location?,
        searchResults: [ShopSearchResult],
        mapDistance: Int
    ) -> [DisplayItem] {
        var items = inRangeShops(
            from: shops,
            disabledShopIds: disabledShopIds,
            currentLocation: currentLocation,
            searchResults: searchResults,
            mapDistance: mapDistance
        )
            .filter { shop in
                tab.id == nil || shop.id == tab.id
            }
            .flatMap { shop in
                shop.items.compactMap { item -> DisplayItem? in
                    guard item.protein >= Double(proteinThreshold.rawValue) else { return nil }
                    guard item.fat <= Double(fatThreshold.rawValue) else { return nil }
                    guard item.type == "主食" else { return nil }
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


