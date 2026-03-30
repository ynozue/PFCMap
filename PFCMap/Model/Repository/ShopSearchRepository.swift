import Foundation
import MapKit

public protocol ShopSearchRepository: Sendable {
    func search(query: String, region: MKCoordinateRegion?) async throws -> [Shop]
}
