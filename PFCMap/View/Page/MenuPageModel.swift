import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class MenuPageModel {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    init() {}
    
    func updateMapDistance(distance: MapDistance, store: PFCMapStore) {
        store.settingsStore.updateMapDistance(distance)
        let service = store.makeUserDefaultsService()
        Task {
            await service.save(key: PFCMapUserDefaultsKeys.mapDistance, value: distance.rawValue)
        }
    }
    
    func updateProteinThreshold(threshold: ProteinThreshold, store: PFCMapStore) {
        store.settingsStore.updateProteinThreshold(threshold)
        let service = store.makeUserDefaultsService()
        Task {
            await service.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: threshold.rawValue)
        }
    }
    
    func updateFatThreshold(threshold: FatThreshold, store: PFCMapStore) {
        store.settingsStore.updateFatThreshold(threshold)
        let service = store.makeUserDefaultsService()
        Task {
            await service.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: threshold.rawValue)
        }
    }
    
#if DEBUG
    func syncAPI(store: PFCMapStore) async {
        print("API 同期開始")
        do {
            let repository = store.makeShopCatalogRepository()
            try await repository.sync()
            let synchronizedShops = try await repository.fetchShops()
            store.shopCatalogStore.updateShops(synchronizedShops)
            print("API 同期完了")
        } catch {
            print("API 同期失敗: \(error)")
        }
    }
    
    func generateDBData(store: PFCMapStore) async {
        print("DB 情報の生成開始")
        do {
            let repository = store.makeShopCatalogRepository()
            try await repository.sync()
            let generatedShops = try await repository.fetchShops()
            store.shopCatalogStore.updateShops(generatedShops)
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
