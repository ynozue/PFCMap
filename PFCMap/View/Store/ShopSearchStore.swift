import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class ShopSearchStore {
    private(set) var results: [ShopSearchResult] = []
    
    init() {}
    
    func updateResults(_ results: [ShopSearchResult]) {
        self.results = results
    }
    
    func clear() {
        self.results = []
    }
}
