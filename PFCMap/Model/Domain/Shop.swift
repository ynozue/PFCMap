import Foundation

public struct Shop: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let menus: [Menu]
    
    public init(id: String = UUID().uuidString, name: String, menus: [Menu] = []) {
        self.id = id
        self.name = name
        self.menus = menus
    }
}
