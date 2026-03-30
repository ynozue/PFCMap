import Foundation
import MapKit

public actor ShopSearchRepositoryImpl: ShopSearchRepository {
    public init() {}
    
    public func search(query: String, region: MKCoordinateRegion?) async throws -> [Shop] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let region = region {
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return await MainActor.run {
            response.mapItems.map { item in
                Shop(
                    id: item.phoneNumber ?? UUID().uuidString,
                    name: item.name ?? "不明な店",
                    location: Location(
                        latitude: item.location.coordinate.latitude,
                        longitude: item.location.coordinate.longitude
                    )
                )
            }
        }
    }
}
