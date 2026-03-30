import Foundation

public struct Shop: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let location: Location
    
    public init(id: String = UUID().uuidString, name: String, location: Location) {
        self.id = id
        self.name = name
        self.location = location
    }
}
