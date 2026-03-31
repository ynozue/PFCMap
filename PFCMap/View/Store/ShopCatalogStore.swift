import SwiftUI
import Observation

@MainActor
@Observable
final class ShopCatalogStore {
    private(set) var shops: [ShopCatalog] = []
    private let remoteClient: any PFCRemoteClient
    private let repository: any ShopCatalogRepository
    
    init(remoteClient: any PFCRemoteClient, repository: any ShopCatalogRepository) {
        self.remoteClient = remoteClient
        self.repository = repository
    }
    
    func load() async throws {
        // First try to fetch from SwiftData
        let fetchedShops = try await repository.fetchShops()
        
        // If empty, fetch from API and save to SwiftData
        if fetchedShops.isEmpty {
            try await sync()
        } else {
            self.shops = fetchedShops
        }
    }

    func sync() async throws {
        try await repository.sync()
        // Reload from DB
        self.shops = try await repository.fetchShops()
    }
}
