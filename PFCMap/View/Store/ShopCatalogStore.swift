import SwiftUI
import Observation

@MainActor
@Observable
public final class ShopCatalogStore {
    public private(set) var shops: [ShopCatalog] = []
    private let remoteClient: any PFCRemoteClient
    private let repository: any ShopCatalogRepository
    
    public init(remoteClient: any PFCRemoteClient, repository: any ShopCatalogRepository) {
        self.remoteClient = remoteClient
        self.repository = repository
    }
    
    public func load() async throws {
        // First try to fetch from SwiftData
        let fetchedShops = try await repository.fetchShops()
        
        // If empty, fetch from API and save to SwiftData
        if fetchedShops.isEmpty {
            try await sync()
        } else {
            self.shops = fetchedShops
        }
    }

    public func sync() async throws {
        try await repository.sync()
        // Reload from DB
        self.shops = try await repository.fetchShops()
    }
}
