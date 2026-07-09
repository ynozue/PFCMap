import Foundation

struct ShopSearchResult: Identifiable, Sendable, Equatable {
    let id: UUID
    let name: String
    let query: String
    let location: Location
    
    nonisolated init(id: UUID = UUID(), name: String, query: String, location: Location) {
        self.id = id
        self.name = name
        self.query = query
        self.location = location
    }
}
