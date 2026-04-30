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
    
    func onAppear(isInitialized: Binding<Bool>, isTutorialCompleted: Binding<Bool>) async {
        guard !isInitialized.wrappedValue else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let completed = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
            isTutorialCompleted.wrappedValue = completed
            
            try await shopCatalogRepository.sync()
            
            isInitialized.wrappedValue = true
        } catch {
            print("Initialization failed: \(error)")
            errorMessage = "情報の初期化に失敗しました。\(error.localizedDescription)"
        }
    }
}
