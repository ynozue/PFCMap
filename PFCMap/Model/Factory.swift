import Foundation
import SwiftData
import NZData

enum PFCMapEnv {
    case prod
    case dev
    case preview
}

final class Factory: @unchecked Sendable {
    let env: PFCMapEnv

    // SwiftData ModelContainer をスレッド安全に遅延初期化するための静的定数
    // マイグレーション失敗などで開けない場合はストアを破棄して再作成する
    private static let sharedContainer: ModelContainer = {
        do {
            return try ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self)
        } catch {
            print("ModelContainer creation failed, recreating store: \(error)")
            let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: storeURL)
            return try! ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self)
        }
    }()

    // Repository/Service を単一インスタンスとして共有するためのキャッシュ
    @MainActor private var cachedLocationRepository: (any LocationRepository)?
    @MainActor private var cachedShopSearchRepository: (any ShopSearchRepository)?
    @MainActor private var cachedShopCatalogRepository: (any ShopCatalogRepository)?
    @MainActor private var cachedUserDefaultsService: (any UserDefaultsService)?
    @MainActor private var cachedImageRepository: (any ImageRepository)?
    @MainActor private var cachedAnalyticsService: (any AnalyticsService)?

    private init(env: PFCMapEnv) {
        self.env = env
    }

    static func create(env: PFCMapEnv) -> Factory {
        return Factory(env: env)
    }

    @MainActor
    private var container: ModelContainer {
        return Self.sharedContainer
    }

    /// ModelContainer をバックグラウンドで先行初期化（ウォームアップ）する
    func warmupContainer() {
        guard env != .preview else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            _ = Self.sharedContainer
        }
    }
}

extension Factory {
    @MainActor
    func makeLocationRepository() -> any LocationRepository {
        if let cached = cachedLocationRepository { return cached }
        let repository: any LocationRepository
        switch env {
        case .prod, .dev:
            repository = LocationRepositoryImpl()
        case .preview:
            repository = LocationRepositoryDummy()
        }
        cachedLocationRepository = repository
        return repository
    }

    @MainActor
    func makeShopSearchRepository() -> any ShopSearchRepository {
        if let cached = cachedShopSearchRepository { return cached }
        let repository: any ShopSearchRepository
        switch env {
        case .prod, .dev:
            repository = ShopSearchRepositoryImpl()
        case .preview:
            repository = ShopSearchRepositoryDummy()
        }
        cachedShopSearchRepository = repository
        return repository
    }
    
    @MainActor
    func makePFCRemoteClient() -> any PFCRemoteClient {
        switch env {
        case .prod:
            return PFCRemoteClientImpl(domain: "pfcmap.noz.app")
        case .dev:
            return PFCRemoteClientImpl(domain: "pfcmap.noz.app")
                // TODO: dev 環境を用意
//            return PFCRemoteClientImpl(domain: "pfcmap-492114.an.r.appspot.com")
        case .preview:
            return PFCRemoteClientDummy()
        }
    }
    
    @MainActor
    func makeShopCatalogRepository() -> any ShopCatalogRepository {
        if let cached = cachedShopCatalogRepository { return cached }
        let repository: any ShopCatalogRepository
        switch env {
        case .prod, .dev:
            repository = ShopCatalogRepositoryImpl(
                remoteClient: makePFCRemoteClient(),
                discordRemoteClient: makeDiscordRemoteClient(),
                modelContainer: container,
                userDefaultsService: makeUserDefaultsService()
            )
        case .preview:
            repository = ShopCatalogRepositoryDummy()
        }
        cachedShopCatalogRepository = repository
        return repository
    }
    
    @MainActor
    func makeDiscordRemoteClient() -> any DiscordRemoteClient {
        switch env {
        case .prod, .dev:
            // Discord Webhook URL
            return DiscordRemoteClientImpl(webhookUrl: "https://discord.com/api/webhooks/1496474470075072536/53NaZ4vmuGcgxmfndHdm6D-Jt8L1bIycNlY7J3JDjecFpI1FRkUah2JvTKyAjaEwpHgc")
        case .preview:
            return DiscordRemoteClientDummy()
        }
    }
    
    @MainActor
    func makeUserDefaultsService() -> any UserDefaultsService {
        if let cached = cachedUserDefaultsService { return cached }
        let service: any UserDefaultsService
        switch env {
        case .prod, .dev:
            service = UserDefaultsServiceImpl()
        case .preview:
            service = UserDefaultsServiceDummy()
        }
        cachedUserDefaultsService = service
        return service
    }

    @MainActor
    func makeImageRepository() -> any ImageRepository {
        if let cached = cachedImageRepository { return cached }
        let repository: any ImageRepository
        switch env {
        case .prod, .dev:
            repository = ImageRepositoryImpl()
        case .preview:
            repository = ImageRepositoryDummy()
        }
        cachedImageRepository = repository
        return repository
    }

    @MainActor
    func makeAnalyticsService() -> any AnalyticsService {
        if let cached = cachedAnalyticsService { return cached }
        let service: any AnalyticsService
        switch env {
        case .prod, .dev:
            service = AnalyticsServiceImpl()
        case .preview:
            service = AnalyticsServiceDummy()
        }
        cachedAnalyticsService = service
        return service
    }
}

extension Factory {
    @MainActor
    func makeHomePageModel(store: Store) -> HomePageModel {
        HomePageModel(
            store: store,
            locationRepository: makeLocationRepository(),
            shopSearchRepository: makeShopSearchRepository(),
            analyticsService: makeAnalyticsService()
        )
    }

    @MainActor
    func makeSplashPageModel(store: Store) -> SplashPageModel {
        SplashPageModel(
            store: store,
            userDefaultsService: makeUserDefaultsService(),
            locationRepository: makeLocationRepository()
        )
    }

    @MainActor
    func makeTutorialPageModel(store: Store) -> TutorialPageModel {
        TutorialPageModel(
            store: store,
            userDefaultsService: makeUserDefaultsService(),
            locationRepository: makeLocationRepository(),
            analyticsService: makeAnalyticsService()
        )
    }

    @MainActor
    func makeShopSettingPageModel(store: Store) -> ShopSettingPageModel {
        ShopSettingPageModel(store: store)
    }

    @MainActor
    func makeMenuPageModel(store: Store) -> MenuPageModel {
        MenuPageModel(
            store: store,
            shopCatalogRepository: makeShopCatalogRepository(),
            userDefaultsService: makeUserDefaultsService()
        )
    }

    @MainActor
    func makeShopItemRowViewModel() -> ShopItemRowViewModel {
        ShopItemRowViewModel(
            repository: makeShopCatalogRepository(),
            imageRepository: makeImageRepository()
        )
    }
}

import SwiftUI

private struct FactoryKey: EnvironmentKey {
    static let defaultValue: Factory = Factory.create(env: .prod)
}

extension EnvironmentValues {
    var factory: Factory {
        get { self[FactoryKey.self] }
        set { self[FactoryKey.self] = newValue }
    }
}
