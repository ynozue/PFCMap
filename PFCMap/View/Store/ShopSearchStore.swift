import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class ShopSearchStore {
    var shops: [Shop] = []
    private let shopSearchRepository: any ShopSearchRepository
    
    init(shopSearchRepository: any ShopSearchRepository) {
        self.shopSearchRepository = shopSearchRepository
    }
    
    func search(query: String, region: MKCoordinateRegion?) async throws {
        self.shops = try await shopSearchRepository.search(query: query, region: region)
    }
    
    func clear() {
        self.shops = []
    }
}
