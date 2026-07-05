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
    private static let sharedContainer: ModelContainer = {
        try! ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self, ImageCacheEntity.self)
    }()
    
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
        switch env {
        case .prod, .dev:
            return LocationRepositoryImpl()
        case .preview:
            return LocationRepositoryDummy()
        }
    }
    
    @MainActor
    func makeShopSearchRepository() -> any ShopSearchRepository {
        switch env {
        case .prod, .dev:
            return ShopSearchRepositoryImpl()
        case .preview:
            return ShopSearchRepositoryDummy()
        }
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
        switch env {
        case .prod, .dev:
            let remoteClient = makePFCRemoteClient()
            let discordRemoteClient = makeDiscordRemoteClient()
            let userDefaultsService = makeUserDefaultsService()
            return ShopCatalogRepositoryImpl(
                remoteClient: remoteClient,
                discordRemoteClient: discordRemoteClient,
                modelContainer: container,
                userDefaultsService: userDefaultsService
            )
        case .preview:
            return ShopCatalogRepositoryDummy()
        }
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
        switch env {
        case .prod, .dev:
            return UserDefaultsServiceImpl()
        case .preview:
            return UserDefaultsServiceDummy()
        }
    }
    
    @MainActor
    func makeImageRepository() -> any ImageRepository {
        switch env {
        case .prod, .dev:
            return ImageRepositoryImpl(modelContainer: container)
        case .preview:
            return ImageRepositoryDummy()
        }
    }
}

extension Factory {
    @MainActor
    func makeHomePageModel() -> HomePageModel {
        HomePageModel(
            locationRepository: makeLocationRepository(),
            shopCatalogRepository: makeShopCatalogRepository(),
            shopSearchRepository: makeShopSearchRepository(),
            userDefaultsService: makeUserDefaultsService()
        )
    }
    
    @MainActor
    func makeSplashPageModel() -> SplashPageModel {
        SplashPageModel(
            shopCatalogRepository: makeShopCatalogRepository(),
            userDefaultsService: makeUserDefaultsService(),
            locationRepository: makeLocationRepository()
        )
    }
    
    @MainActor
    func makeTutorialPageModel() -> TutorialPageModel {
        TutorialPageModel(
            shopCatalogRepository: makeShopCatalogRepository(),
            userDefaultsService: makeUserDefaultsService(),
            locationRepository: makeLocationRepository()
        )
    }
    
    @MainActor
    func makeShopSettingPageModel() -> ShopSettingPageModel {
        ShopSettingPageModel(
            shopCatalogRepository: makeShopCatalogRepository(),
            userDefaultsService: makeUserDefaultsService()
        )
    }
    
    @MainActor
    func makeMenuPageModel() -> MenuPageModel {
        MenuPageModel(
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
