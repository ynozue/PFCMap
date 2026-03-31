import SwiftUI
import Observation

@MainActor
@Observable
final class MenuPageModel {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    init() {}
    
#if DEBUG
    func syncAPI(store: PFCMapStore) async {
        print("API 同期開始")
        do {
            try await store.shopCatalogStore.sync()
            print("API 同期完了")
        } catch {
            print("API 同期失敗: \(error)")
        }
    }
    
    func generateDBData(store: PFCMapStore) async {
        print("DB 情報の生成開始")
        do {
            // ここでは同期処理を行うことでデータを生成する
            try await store.shopCatalogStore.sync()
            print("DB 情報の生成完了")
        } catch {
            print("DB 情報の生成失敗: \(error)")
        }
    }
    
    func triggerCrash() {
        fatalError("Debug: Intentional App Crash")
    }
#endif
}
