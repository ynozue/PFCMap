import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class SplashPageModel {
    var isLoading = false
    var errorMessage: String?
    
    private let store: Store
    private let userDefaultsService: any UserDefaultsService
    private let locationRepository: any LocationRepository

    init(
        store: Store,
        userDefaultsService: any UserDefaultsService,
        locationRepository: any LocationRepository
    ) {
        self.store = store
        self.userDefaultsService = userDefaultsService
        self.locationRepository = locationRepository
    }

    func initialize(isTutorialCompleted: Binding<Bool>) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        // 位置情報のプリフェッチをバックグラウンドで開始
        locationRepository.prefetchLocation()

        let clock = ContinuousClock()
        do {
            let totalElapsed = try await clock.measure {
                let completed = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
                isTutorialCompleted.wrappedValue = completed

                let fetchElapsed = try await clock.measure {
                    try await store.refreshShops()
                }
                print("⏱️ [Startup] SwiftData Fetch (and Container Initialization): \(fetchElapsed)")

                if !store.shops.isEmpty {
                    // キャッシュがある場合は同期処理をバックグラウンドで行う
                    // 完了すると store.shops が更新され、Observation 経由で各画面に反映される
                    Task { [store] in
                        do {
                            try await store.syncShops()
                        } catch {
                            print("Background sync failed: \(error)")
                        }
                    }
                } else {
                    // キャッシュがない場合は同期的に完了を待つ
                    let syncElapsed = try await clock.measure {
                        try await store.syncShops()
                    }
                    print("⏱️ [Startup] Sync API (No Cache): \(syncElapsed)")
                }
            }
            print("⏱️ [Startup] Total SplashPageModel Initialization: \(totalElapsed)")
            return true
        } catch {
            print("Initialization failed: \(error)")
            errorMessage = "情報の初期化に失敗しました。\(error.localizedDescription)"
            return false
        }
    }
}
