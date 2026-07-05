import Foundation
import FirebaseAnalytics

struct AnalyticsServiceImpl: AnalyticsService {
    func logTutorialComplete() {
        Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
    }
    
    func logSearch(proteinThreshold: Int, fatThreshold: Int, mapDistance: Int) {
        Analytics.logEvent("search_execute", parameters: [
            "protein_threshold": proteinThreshold,
            "fat_threshold": fatThreshold,
            "map_distance": mapDistance
        ])
    }
    
    func logViewShopDetail(shopName: String) {
        Analytics.logEvent("view_shop_detail", parameters: [
            "shop_name": shopName
        ])
    }
    
    func logShare(menuName: String, shopName: String) {
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: "pfc_card",
            AnalyticsParameterItemID: menuName,
            "shop_name": shopName
        ])
    }
}
