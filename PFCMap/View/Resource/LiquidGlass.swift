import SwiftUI

extension ShapeStyle where Self == AnyShapeStyle {
    /// プレミアムな質感を持つ独自のスタイル
    static var liquidGlass: AnyShapeStyle {
        AnyShapeStyle(
            .ultraThinMaterial
                .opacity(0.9)
        )
    }
}

extension View {
    /// LiquidGlass の背景とスタイルを適用するショートカット
    func liquidGlassBackground(cornerRadius: CGFloat = 24) -> some View {
        self.background(.liquidGlass)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}
