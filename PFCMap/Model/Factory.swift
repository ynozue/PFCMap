import Foundation

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
}
