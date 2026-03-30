import Foundation
// import NZCore

public actor PFCRemoteClientImpl: PFCRemoteClient {
    public init() {}
    
    public func fetchShops() async throws -> [ShopCatalogResponseDTO] {
        // API 未実装のため
        throw NSError(domain: "PFCRemoteClientImpl", code: 0, userInfo: [NSLocalizedDescriptionKey: "API not implemented"])
    }
}
