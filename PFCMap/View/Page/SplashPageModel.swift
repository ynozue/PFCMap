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
            // カタログデータの読み取り（SwiftData）
            try await store.shopCatalogStore.load()
            
            // 設定データの読み込み（UserDefaults）
            await store.settingsStore.loadSettings()
            
            // ロード完了
            store.isInitialized = true
        } catch {
            errorMessage = "データの初期化に失敗しました。\(error.localizedDescription)"
        }
    }
}
