import SwiftUI
import Observation

@MainActor
@Observable
public final class ShopCatalogStore {
    public private(set) var shops: [Shop] = []
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
            let remoteShops = try await remoteClient.fetchShops()
            let domainShops = remoteShops.map { dto in
                Shop(
                    id: dto.id,
                    name: dto.name,
                    menus: dto.menus.map { mdto in
                        Menu(
                            id: mdto.id,
                            name: mdto.name,
                            calorie: mdto.calorie,
                            protein: mdto.protein,
                            fat: mdto.fat,
                            carbohydrate: mdto.carbohydrate
                        )
                    }
                )
            }
            try await repository.saveShops(domainShops)
            self.shops = domainShops
        } else {
            self.shops = fetchedShops
        }
    }
}
