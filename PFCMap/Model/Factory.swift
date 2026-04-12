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
    private static var _container: ModelContainer?
    
    private init(env: PFCMapEnv) {
        self.env = env
    }
    
    static func create(env: PFCMapEnv) -> Factory {
        return Factory(env: env)
    }
    
    @MainActor
    private var container: ModelContainer {
        if let existing = Self._container {
            return existing
        }
        let newContainer = try! ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self)
        Self._container = newContainer
        return newContainer
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
            return PFCRemoteClientImpl(domain: "pfcmap-api-196850882055.asia-northeast1.run.app")
        case .preview:
            return PFCRemoteClientDummy()
        }
    }
    
    @MainActor
    func makeShopCatalogRepository() -> any ShopCatalogRepository {
        switch env {
        case .prod, .dev:
            let remoteClient = makePFCRemoteClient()
            let userDefaultsService = makeUserDefaultsService()
            return ShopCatalogRepositoryImpl(remoteClient: remoteClient, modelContainer: container, userDefaultsService: userDefaultsService)
        case .preview:
            return ShopCatalogRepositoryDummy()
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
}
