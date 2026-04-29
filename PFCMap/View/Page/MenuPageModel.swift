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
    var privacyPolicyURL: URL? = nil
    
    private let shopCatalogRepository: any ShopCatalogRepository
    private let userDefaultsService: any UserDefaultsService
    
    init(shopCatalogRepository: any ShopCatalogRepository, userDefaultsService: any UserDefaultsService) {
        self.shopCatalogRepository = shopCatalogRepository
        self.userDefaultsService = userDefaultsService
    }
    
    func onAppear() async {
        self.lastFetchedAt = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
    }
    
    func lastSyncDateString(date: Date?) -> String {
        guard let date = date else { return "未同期" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: date)
    }

#if DEBUG
    func syncAPI() async {
        print("API 同期開始")
        do {
            try await shopCatalogRepository.sync(force: true)
            self.lastFetchedAt = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            print("API 同期完了")
        } catch {
            print("API 同期失敗: \(error)")
        }
    }
    
    func generateDBData() async {
        print("DB 情報の生成開始")
        do {
            try await shopCatalogRepository.sync(force: true)
            self.lastFetchedAt = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            print("DB 情報の生成完了")
        } catch {
            print("DB 情報の生成失敗: \(error)")
        }
    }
    
    func deleteLastSyncDate() async {
        await userDefaultsService.remove(key: PFCMapUserDefaultsKeys.lastFetchedAt)
        self.lastFetchedAt = nil
    }
    
    func deleteTutorialFlag() async {
        await userDefaultsService.remove(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
    }
    
    func clearDB() async {
        print("DB クリア開始")
        do {
            try await shopCatalogRepository.clearAll()
            
            // すべての UserDefaults をデフォルト値に戻す
            await userDefaultsService.remove(key: PFCMapUserDefaultsKeys.lastFetchedAt)
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.mapDistance, value: PFCMapUserDefaultsKeys.mapDistance.defaultValue)
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: PFCMapUserDefaultsKeys.proteinThreshold.defaultValue)
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: PFCMapUserDefaultsKeys.fatThreshold.defaultValue)
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: PFCMapUserDefaultsKeys.disabledShopIds.defaultValue)
            await userDefaultsService.remove(key: PFCMapUserDefaultsKeys.isTutorialCompleted)
            
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
