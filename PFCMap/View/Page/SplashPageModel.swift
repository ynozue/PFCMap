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
    
    init(shopCatalogRepository: any ShopCatalogRepository, userDefaultsService: any UserDefaultsService) {
        self.shopCatalogRepository = shopCatalogRepository
        self.userDefaultsService = userDefaultsService
    }
    
    func initialize(isTutorialCompleted: Binding<Bool>) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let completed = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
            isTutorialCompleted.wrappedValue = completed
            
            let localShops = try await shopCatalogRepository.fetchShops()
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
                try await shopCatalogRepository.sync()
            }
            return true
        } catch {
            print("Initialization failed: \(error)")
            errorMessage = "情報の初期化に失敗しました。\(error.localizedDescription)"
            return false
        }
    }
}
