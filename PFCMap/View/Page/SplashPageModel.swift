import SwiftUI
import Observation

@MainActor
@Observable
final class SplashPageModel {
    var isLoading = false
    var errorMessage: String?
    
    init() {}
    
    func onAppear(store: PFCMapStore) async {
        guard !store.isInitialized else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // カタログデータの読み込み
            try await store.shopCatalogStore.load()
            
            // 現在地の取得
            try await store.locationStore.fetchCurrentLocation()
            
            // 近くの店舗の検索 (500m以内)
            if let currentLocation = store.locationStore.currentLocation {
                let shops = store.shopCatalogStore.shops
                let queries = shops.map { $0.name }
                
                // 検索リポジトリは Store 内にあるが、SplashPageModel は Store を通じて直接叩く
                try await store.shopSearchStore.search(
                    queries: queries,
                    region: store.locationStore.currentRegion(radius: 1000)
                )
                let searchResults = store.shopSearchStore.results
                
                // 初期化時の検索結果はクリアしておく（MapPageで改めて行われるため）
                store.shopSearchStore.clear()
            }
            
            // ロード完了
            store.isInitialized = true
        } catch {
            errorMessage = "データの初期化に失敗しました。\(error.localizedDescription)"
        }
    }
}
