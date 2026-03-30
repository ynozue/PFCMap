import Foundation
import MapKit

public actor ShopSearchRepositoryImpl: ShopSearchRepository {
    public init() {}
    
    public func search(queries: [String], region: MKCoordinateRegion?) async throws -> [Shop] {
        try await withThrowingTaskGroup(of: [Shop].self) { group in
            for query in queries {
                group.addTask {
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
            
            var allShops: [Shop] = []
            var seenIds = Set<String>()
            for try await shops in group {
                for shop in shops {
                    if !seenIds.contains(shop.id) {
                        allShops.append(shop)
                        seenIds.insert(shop.id)
                    }
                }
            }
            return allShops
        }
    }
}
