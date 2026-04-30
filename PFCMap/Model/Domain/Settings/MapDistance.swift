import Foundation

enum MapDistance: Int, CaseIterable, Sendable {
    case m300 = 300
    case m500 = 500
    case m1000 = 1000
    case m1500 = 1500
    
    var label: String {
        "\(rawValue.formatted())m"
    }
}
