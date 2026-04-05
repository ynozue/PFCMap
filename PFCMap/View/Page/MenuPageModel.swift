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
    
    func lastSyncDateString(date: Date?) -> String {
        guard let date = date else { return "未同期" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH時mm分ss秒"
        return formatter.string(from: date)
    }

#if DEBUG
    func syncAPI(store: PFCMapStore) async {
        print("API 同期開始")
        do {
            let repository = store.makeShopCatalogRepository()
            try await repository.sync()
            let synchronizedShops = try await repository.fetchShops()
            store.shopCatalogStore.updateShops(synchronizedShops)
            
            // 最終同期日時を Store に反映
            let service = store.makeUserDefaultsService()
            let lastFetchedAt: Date? = await service.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            store.settingsStore.updateLastFetchedAt(lastFetchedAt)
            
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
            
            // 最終同期日時を Store に反映
            let service = store.makeUserDefaultsService()
            let lastFetchedAt: Date? = await service.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            store.settingsStore.updateLastFetchedAt(lastFetchedAt)
            
            print("DB 情報の生成完了")
        } catch {
            print("DB 情報の生成失敗: \(error)")
        }
    }
    
    func deleteLastSyncDate(store: PFCMapStore) async {
        let service = store.makeUserDefaultsService()
        await service.remove(key: PFCMapUserDefaultsKeys.lastFetchedAt)
        store.settingsStore.updateLastFetchedAt(nil)
    }
    
    func clearDB(store: PFCMapStore) async {
        print("DB クリア開始")
        do {
            let repository = store.makeShopCatalogRepository()
            try await repository.clearAll()
            
            let service = store.makeUserDefaultsService()
            // すべての UserDefaults をデフォルト値に戻す
            await service.remove(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            await service.save(key: PFCMapUserDefaultsKeys.mapDistance, value: PFCMapUserDefaultsKeys.mapDistance.defaultValue)
            await service.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: PFCMapUserDefaultsKeys.proteinThreshold.defaultValue)
            await service.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: PFCMapUserDefaultsKeys.fatThreshold.defaultValue)
            await service.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: PFCMapUserDefaultsKeys.disabledShopIds.defaultValue)
            
            store.clearAllData()
            
            print("DB クリア完了")
        } catch {
            print("DB クリア失敗: \(error)")
        }
    }
    
    func triggerCrash() {
        fatalError("Debug: Intentional App Crash")
    }
#endif
}
