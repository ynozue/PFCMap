import SwiftUI

extension Color {
    /// P (Protein): 赤 - 身体をつくる
    static let pColor = Color(red: 0.90, green: 0.18, blue: 0.18)
    
    /// F (Fat): 黄 - エネルギーになる
    static let fColor = Color(red: 0.96, green: 0.72, blue: 0.08)
    
    /// C (Carbohydrate): 緑 - 調子を整える
    static let cColor = Color(red: 0.15, green: 0.68, blue: 0.22)
    
    /// Nutrients mapping
    static func nutrientColor(for name: String) -> Color {
        switch name.uppercased() {
        case "P": return .pColor
        case "F": return .fColor
        case "C": return .cColor
        default: return .primary
        }
    }
}
