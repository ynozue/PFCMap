import Foundation

public struct ShopSearchResult: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let location: Location
    
    public init(id: UUID = UUID(), name: String, location: Location) {
        self.id = id
        self.name = name
        self.location = location
    }
}
