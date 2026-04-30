import Foundation
import NZCore

actor PFCRemoteClientImpl: PFCRemoteClient {
    private let client: RemoteClient

    init(domain: String) {
        client = RemoteClient(baseUrl: "http://\(domain)")
    }

    func fetchShops(request: ShopCatalogRequestDTO) async throws -> ShopCatalogResponseDTO {
        let headers = generateHeaders()
        return try await client.get(
            path: "/shops",
            headers: headers,
            querys: ["last_fetch_date": request.lastFetchDate.map(\.description) ?? ""]
        )
    }

    private func generateHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
}
