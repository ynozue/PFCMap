import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class ShopSearchStore {
    var results: [ShopSearchResult] = []
    private let shopSearchRepository: any ShopSearchRepository
    
    init(shopSearchRepository: any ShopSearchRepository) {
        self.shopSearchRepository = shopSearchRepository
    }
    
    func search(queries: [String], region: MKCoordinateRegion?) async throws {
        self.results = try await shopSearchRepository.search(queries: queries, region: region)
    }
    
    func clear() {
        self.results = []
    }
}
