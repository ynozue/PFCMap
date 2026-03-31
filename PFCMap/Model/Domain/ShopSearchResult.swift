import Foundation

public struct ShopSearchResult: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let query: String
    public let location: Location
    
    public init(id: UUID = UUID(), name: String, query: String, location: Location) {
        self.id = id
        self.name = name
        self.query = query
        self.location = location
    }
}
