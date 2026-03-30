import Foundation

// TODO: Implement Factory for DI
struct PFCMapEnv {
    // Protocol definition for project environment
}

extension PFCMapEnv {
    static let prod = "prod"
    static let dev = "dev"
    static let preview = "preview"
}

class Factory {
    static func create(env: String) {
        // Init factory logic
    }
}
