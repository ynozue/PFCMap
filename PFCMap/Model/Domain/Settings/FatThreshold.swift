import Foundation

public enum FatThreshold: Int, CaseIterable, Sendable {
    case g15 = 15
    case g20 = 20
    case g25 = 25
    case g30 = 30
    
    public var label: String {
        "\(rawValue)g"
    }
}
