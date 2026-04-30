import SwiftUI

@MainActor
struct AppLogoView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            // ドロップシャドウ用
            AppMapPinShape()
                .fill(Color.black.opacity(0.1))
                .frame(width: size, height: size * 1.3)
                .offset(y: size * 0.08)
                .blur(radius: size * 0.08)

            // ピン本体（白）
            AppMapPinShape()
                .fill(Color.white)
                .frame(width: size, height: size * 1.3)
                .overlay {
                    AppMapPinShape()
                        .stroke(Color.gray.opacity(0.18), lineWidth: size * 0.008)
                }

            // ピン内のグロス（光沢）
            AppMapPinShape()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .frame(width: size, height: size * 1.3)

            // PFC バー（アイコンの中央部分）
            HStack(alignment: .bottom, spacing: size * 0.08) {
                // P：赤
                Capsule()
                    .fill(Color.pColor)
                    .frame(width: size * 0.11, height: size * 0.4)
                    .shadow(color: Color.pColor.opacity(0.35), radius: size * 0.02, x: 0, y: size * 0.015)
                // F：黄
                Capsule()
                    .fill(Color.fColor)
                    .frame(width: size * 0.11, height: size * 0.27)
                    .shadow(color: Color.fColor.opacity(0.35), radius: size * 0.02, x: 0, y: size * 0.015)
                // C：緑
                Capsule()
                    .fill(Color.cColor)
                    .frame(width: size * 0.11, height: size * 0.47)
                    .shadow(color: Color.cColor.opacity(0.35), radius: size * 0.02, x: 0, y: size * 0.015)
            }
            .offset(y: -size * 0.18)
        }
    }
}


struct AppMapPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let r = w / 2          // 円の半径
        let cx = w / 2         // 円の中心 X
        let cy = r             // 円の中心 Y（上から半径分）

        var path = Path()
        path.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: r,
            startAngle: .degrees(150),
            endAngle: .degrees(30),
            clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: cx, y: h),
            control1: CGPoint(x: w * 0.92, y: h * 0.58),
            control2: CGPoint(x: cx + r * 0.3, y: h * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: cx - r * cos(.pi / 6), y: cy + r * sin(.pi / 6)),
            control1: CGPoint(x: cx - r * 0.3, y: h * 0.88),
            control2: CGPoint(x: w * 0.08, y: h * 0.58)
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        AppLogoView(size: 180)
        AppLogoView(size: 100)
    }
}
