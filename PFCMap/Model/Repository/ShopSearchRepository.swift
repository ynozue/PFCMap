import Foundation
import MapKit

protocol ShopSearchRepository: Sendable {
    func search(queries: [String], region: MKCoordinateRegion?) async throws -> [ShopSearchResult]
}
