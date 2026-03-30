import SwiftUI
import Observation

@MainActor
@Observable
final class MenuPageModel {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    init() {}
    
    func syncAPI() async {
        // API 同期のロジックをここに記述
        print("API 同期開始")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("API 同期完了")
    }
    
    func generateDBData() async {
        // DB 情報の生成ロジックをここに記述
        print("DB 情報の生成開始")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("DB 情報の生成完了")
    }
    
    func triggerCrash() {
        fatalError("Debug: Intentional App Crash")
    }
}
