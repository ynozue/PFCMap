import SwiftUI
import Observation

@MainActor
@Observable
final class PFCMapStore {
    // データ毎のStoreを保持するが、今のところは空で作成
    // 例: @ObservationIgnored var userStore = UserStore()
    
    init(factory: Factory) {
        // Factoryからリポジトリを取得してStoreの初期化など
    }
}
