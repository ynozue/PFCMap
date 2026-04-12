import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class SplashPageModel {
    var isLoading = false
    var errorMessage: String?
    
    init() {}
    
    func onAppear(factory: Factory, isInitialized: Binding<Bool>) async {
        guard !isInitialized.wrappedValue else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let repository = factory.makeShopCatalogRepository()
            try await repository.sync()
            
            isInitialized.wrappedValue = true
        } catch {
            print("Initialization failed: \(error)")
            errorMessage = "情報の初期化に失敗しました。\(error.localizedDescription)"
        }
    }
}
