import Foundation
import MapKit

actor ShopSearchRepositoryImpl: ShopSearchRepository {
    init() {}
    
    func search(queries: [String], region: MKCoordinateRegion?) async throws -> [ShopSearchResult] {
        await withTaskGroup(of: [ShopSearchResult].self) { group in
            for (index, query) in queries.enumerated() {
                group.addTask {
                    // 簡易的な待機（並行アクセス過多によるエラーを軽減するため、少しばらつきを持たせる）
                    try? await Task.sleep(nanoseconds: UInt64(index) * 200_000_000)

                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = query
                    if let region = region {
                        request.region = region
                    }

                    let search = MKLocalSearch(request: request)
                    do {
                        let response = try await search.start()
                        return response.mapItems.map { item in
                            ShopSearchResult(
                                name: item.name ?? "不明な店",
                                query: query,
                                location: Location(
                                    latitude: item.location.coordinate.latitude,
                                    longitude: item.location.coordinate.longitude
                                )
                            )
                        }
                    } catch {
                        print("Search error for query '\(query)': \(error.localizedDescription)")
                        return []
                    }
                }
            }

            var allShops: [ShopSearchResult] = []
            var seenIds = Set<UUID>()
            for await shops in group {
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
