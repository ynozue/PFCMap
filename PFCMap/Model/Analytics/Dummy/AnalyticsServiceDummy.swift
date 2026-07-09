import Foundation

struct AnalyticsServiceDummy: AnalyticsService {
    func logTutorialComplete() {
        print("[Dummy Analytics] logTutorialComplete")
    }
    
    func logSearch(proteinThreshold: Int, fatThreshold: Int, mapDistance: Int) {
        print("[Dummy Analytics] logSearch: protein=\(proteinThreshold), fat=\(fatThreshold), distance=\(mapDistance)")
    }
    
    func logViewShopDetail(shopName: String) {
        print("[Dummy Analytics] logViewShopDetail: shopName=\(shopName)")
    }
    
    func logShare(menuName: String, shopName: String) {
        print("[Dummy Analytics] logShare: menuName=\(menuName), shopName=\(shopName)")
    }
}
