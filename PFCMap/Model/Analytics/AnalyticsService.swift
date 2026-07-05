import Foundation

protocol AnalyticsService: Sendable {
    /// チュートリアル（オンボーディング）完了イベントを記録
    func logTutorialComplete()
    
    /// 検索実行イベントを記録
    /// - Parameters:
    ///   - proteinThreshold: タンパク質閾値
    ///   - fatThreshold: 脂質閾値
    ///   - mapDistance: 検索半径(m)
    func logSearch(proteinThreshold: Int, fatThreshold: Int, mapDistance: Int)
    
    /// 店舗詳細閲覧イベントを記録
    /// - Parameter shopName: 店舗名
    func logViewShopDetail(shopName: String)
    
    /// シェア実行イベントを記録 (フェーズ3用)
    /// - Parameters:
    ///   - menuName: メニュー名
    ///   - shopName: 店舗名
    func logShare(menuName: String, shopName: String)
}
