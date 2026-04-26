import Foundation

struct ImageCache: Sendable, Identifiable, Equatable {
    var id: String { url }
    let url: String
    let data: Data
    let updatedAt: Date
    
    init(url: String, data: Data, updatedAt: Date = Date()) {
        self.url = url
        self.data = data
        self.updatedAt = updatedAt
    }
}
