import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class MenuPageModel {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var lastFetchedAt: Date? = nil
    
    init() {}
    
    func onAppear(factory: Factory) async {
        let service = factory.makeUserDefaultsService()
        self.lastFetchedAt = await service.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
    }
    
    func lastSyncDateString(date: Date?) -> String {
        guard let date = date else { return "未同期" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH時mm分ss秒"
        return formatter.string(from: date)
    }

#if DEBUG
    func syncAPI(factory: Factory) async {
        print("API 同期開始")
        do {
            let repository = factory.makeShopCatalogRepository()
            try await repository.sync(force: true)
            
            let service = factory.makeUserDefaultsService()
            self.lastFetchedAt = await service.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            
            print("API 同期完了")
        } catch {
            print("API 同期失敗: \(error)")
        }
    }
    
    func generateDBData(factory: Factory) async {
        print("DB 情報の生成開始")
        do {
            let repository = factory.makeShopCatalogRepository()
            try await repository.sync(force: true)
            
            let service = factory.makeUserDefaultsService()
            self.lastFetchedAt = await service.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            
            print("DB 情報の生成完了")
        } catch {
            print("DB 情報の生成失敗: \(error)")
        }
    }
    
    func deleteLastSyncDate(factory: Factory) async {
        let service = factory.makeUserDefaultsService()
        await service.remove(key: PFCMapUserDefaultsKeys.lastFetchedAt)
        self.lastFetchedAt = nil
    }
    
    func deleteTutorialFlag(factory: Factory) async {
        let service = factory.makeUserDefaultsService()
        await service.remove(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
    }
    
    func clearDB(factory: Factory) async {
        print("DB クリア開始")
        do {
            let repository = factory.makeShopCatalogRepository()
            try await repository.clearAll()
            
            let service = factory.makeUserDefaultsService()
            // すべての UserDefaults をデフォルト値に戻す
            await service.remove(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            await service.save(key: PFCMapUserDefaultsKeys.mapDistance, value: PFCMapUserDefaultsKeys.mapDistance.defaultValue)
            await service.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: PFCMapUserDefaultsKeys.proteinThreshold.defaultValue)
            await service.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: PFCMapUserDefaultsKeys.fatThreshold.defaultValue)
            await service.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: PFCMapUserDefaultsKeys.disabledShopIds.defaultValue)
            await service.remove(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
            
            self.lastFetchedAt = nil
            
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
