import Foundation
import MapKit

public protocol ShopSearchRepository: Sendable {
    func search(queries: [String], region: MKCoordinateRegion?) async throws -> [Shop]
}
