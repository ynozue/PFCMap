import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class SplashPageModel {
    var isLoading = false
    var errorMessage: String?
    
    private let shopCatalogRepository: any ShopCatalogRepository
    private let userDefaultsService: any UserDefaultsService
    private let locationRepository: any LocationRepository
    
    init(
        shopCatalogRepository: any ShopCatalogRepository,
        userDefaultsService: any UserDefaultsService,
        locationRepository: any LocationRepository
    ) {
        self.shopCatalogRepository = shopCatalogRepository
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
                
                var localShops: [ShopCatalog] = []
                let fetchElapsed = try await clock.measure {
                    localShops = try await shopCatalogRepository.fetchShops()
                }
                print("⏱️ [Startup] SwiftData Fetch (and Container Initialization): \(fetchElapsed)")
                
                if !localShops.isEmpty {
                    // キャッシュがある場合は同期処理をバックグラウンドで行う
                    Task {
                        do {
                            try await shopCatalogRepository.sync()
                        } catch {
                            print("Background sync failed: \(error)")
                        }
                    }
                } else {
                    // キャッシュがない場合は同期的に完了を待つ
                    let syncElapsed = try await clock.measure {
                        try await shopCatalogRepository.sync()
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
