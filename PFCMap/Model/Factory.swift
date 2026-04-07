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
    
    private init(env: PFCMapEnv) {
        self.env = env
    }
    
    static func create(env: PFCMapEnv) -> Factory {
        return Factory(env: env)
    }
}

extension Factory {
    func makeLocationRepository() -> any LocationRepository {
        switch env {
        case .prod, .dev:
            return LocationRepositoryImpl()
        case .preview:
            return LocationRepositoryDummy()
        }
    }
    
    func makeShopSearchRepository() -> any ShopSearchRepository {
        switch env {
        case .prod, .dev:
            return ShopSearchRepositoryImpl()
        case .preview:
            return ShopSearchRepositoryDummy()
        }
    }
    
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
    
    func makeShopCatalogRepository() -> any ShopCatalogRepository {
        switch env {
        case .prod, .dev:
            // SwiftData 用のコンテナ初期化などは本来 App で行うが、ここでは簡易化のため
            // 実運用上は Factory が保持するか、他から提供するようにする
            let container = try! ModelContainer(for: ShopCatalogEntity.self, ShopItemEntity.self)
            let remoteClient = makePFCRemoteClient()
            let userDefaultsService = makeUserDefaultsService()
            return ShopCatalogRepositoryImpl(remoteClient: remoteClient, modelContainer: container, userDefaultsService: userDefaultsService)
        case .preview:
            return ShopCatalogRepositoryDummy()
        }
    }
    
    func makeUserDefaultsService() -> any UserDefaultsService {
        switch env {
        case .prod, .dev:
            return UserDefaultsServiceImpl()
        case .preview:
            return UserDefaultsServiceDummy()
        }
    }
}
