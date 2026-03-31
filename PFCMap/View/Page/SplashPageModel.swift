import SwiftUI
import Observation
import NZData

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
            // カタログデータの取得と保存
            let repository = store.makeShopCatalogRepository()
            let fetchedShops = try await repository.fetchShops()
            
            if fetchedShops.isEmpty {
                try await repository.sync()
                let syncedShops = try await repository.fetchShops()
                store.shopCatalogStore.updateShops(syncedShops)
            } else {
                store.shopCatalogStore.updateShops(fetchedShops)
            }
            
            // 設定データの読み込み
            let userDefaultsService = store.makeUserDefaultsService()
            let distance: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.mapDistance)
            let mapDistance = MapDistance(rawValue: distance) ?? .m500
            
            let protein: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.proteinThreshold)
            let proteinThreshold = ProteinThreshold(rawValue: protein) ?? .g20
            
            let fat: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.fatThreshold)
            let fatThreshold = FatThreshold(rawValue: fat) ?? .g20

            let ids: [UUID] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
            let disabledShopIds = Set(ids)
            
            store.settingsStore.updateSettings(
                mapDistance: mapDistance,
                proteinThreshold: proteinThreshold,
                fatThreshold: fatThreshold,
                disabledShopIds: disabledShopIds
            )
            
            // ロード完了
            store.isInitialized = true
        } catch {
            print("Initialization failed: \(error)")
            errorMessage = "情報の初期化に失敗しました。\(error.localizedDescription)"
        }
    }
}
