import SwiftUI

// MARK: - SplashPage

@MainActor
struct SplashPage: View {
    @Environment(\.factory) private var factory
    @Binding var isInitialized: Bool
    @Binding var isTutorialCompleted: Bool
    @State private var model: SplashPageModel

    // ── アニメーション状態 ─────────────────────
    /// ピンが画面上部から落ちてくる初期オフセット
    @State private var pinDropOffset: CGFloat = -300
    /// ピン全体のスケール（バウンド表現）
    @State private var pinScale: CGFloat = 1.0
    /// ピンのオパシティ
    @State private var pinOpacity: Double = 0
    /// PFC バーそれぞれの高さ
    @State private var barHeightP: CGFloat = 0
    @State private var barHeightF: CGFloat = 0
    @State private var barHeightC: CGFloat = 0
    /// テキストセクションの表示
    @State private var showText = false

    init(model: SplashPageModel, isInitialized: Binding<Bool>, isTutorialCompleted: Binding<Bool>) {
        self._isInitialized = isInitialized
        self._isTutorialCompleted = isTutorialCompleted
        self._model = State(wrappedValue: model)
    }

    var body: some View {
        ZStack {
            // ── 背景（アイコン背景色に合わせた薄いグレー）────────
            Color(red: 0.92, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            // ── マップ風グリッド ────────────────────────
            MapGridView()
                .ignoresSafeArea()

            // ── メインコンテンツ ────────────────────────
            VStack(spacing: 0) {
                Spacer()

                // ロゴ（アイコンの再現）
                appIconView

                // アプリ名・サブタイトル
                textSection
                    .padding(.top, 36)

                Spacer()

                // ローディング インジケータ
                loadingSection
                    .frame(height: 60)

                Spacer()
                    .frame(height: 56)
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            Task {
                let clock = ContinuousClock()
                let totalStartupElapsed = await clock.measure {
                    async let runAnim: () = runAnimations()
                    async let isSuccess = model.initialize(isTutorialCompleted: $isTutorialCompleted)
                    
                    // アニメーション完了とデータ初期化を並行して待ち、初期化が成功した場合のみ遷移
                    let (_, success) = await (runAnim, isSuccess)
                    if success {
                        withAnimation {
                            isInitialized = true
                        }
                    }
                }
                print("⏱️ [Startup] Splash to Home Screen Total Transition Time: \(totalStartupElapsed)")
            }
        }
        .alert("エラー", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("再試行") {
                Task {
                    let success = await model.initialize(isTutorialCompleted: $isTutorialCompleted)
                    if success {
                        withAnimation {
                            isInitialized = true
                        }
                    }
                }
            }
        } message: {
            if let message = model.errorMessage { Text(message) }
        }
    }

    // MARK: - Sub Views

    /// アプリアイコンを SwiftUI で忠実に再現したロゴ
    private var appIconView: some View {
        ZStack(alignment: .center) {
            // ドロップシャドウ用
            AppMapPinShape()
                .fill(Color.black.opacity(0.1))
                .frame(width: 180, height: 234)
                .offset(y: 14)
                .blur(radius: 14)

            // ピン本体（白）
            AppMapPinShape()
                .fill(Color.white)
                .frame(width: 180, height: 234)
                .overlay {
                    AppMapPinShape()
                        .stroke(Color.gray.opacity(0.18), lineWidth: 1.5)
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
                .frame(width: 180, height: 234)

            // PFC バー（アイコンの中央部分）
            // アイコン上部（円の中心）に配置し、ピン全体の上 40 % あたりに位置させる
            HStack(alignment: .bottom, spacing: 14) {
                // P：赤
                SplashBarView(
                    color: .pColor,
                    shadowColor: Color.pColor.opacity(0.35),
                    height: barHeightP
                )
                // F：黄
                SplashBarView(
                    color: .fColor,
                    shadowColor: Color.fColor.opacity(0.35),
                    height: barHeightF
                )
                // C：緑
                SplashBarView(
                    color: .cColor,
                    shadowColor: Color.cColor.opacity(0.35),
                    height: barHeightC
                )
            }
            // ピンの円形部分の中央（上から約 45%）に配置
            .offset(y: -32)
        }
        .offset(y: pinDropOffset)
        .scaleEffect(pinScale)
        .opacity(pinOpacity)
    }

    private var textSection: some View {
        VStack(spacing: 10) {
            Text("PFCMap")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundStyle(Color(white: 0.15))
                .tracking(1.0)

            Text("Macro Balanced Map")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(white: 0.45))
                .tracking(1.8)
        }
        .opacity(showText ? 1 : 0)
        .offset(y: showText ? 0 : 16)
    }

    private var loadingSection: some View {
        VStack(spacing: 10) {
            ProgressView()
                .tint(Color(white: 0.45))
            Text("データを読み込み中...")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(white: 0.55))
        }
        .opacity(model.isLoading ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: model.isLoading)
    }

    // MARK: - Animation

    private func runAnimations() async {
        // 1. ピンが上から落下（速度を上げてより軽快に）
        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
            pinDropOffset = 0
            pinOpacity = 1
        }

        // 少し待ってからバウンド強調
        try? await Task.sleep(nanoseconds: 30_000_000) // 30ms
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            pinScale = 0.93
        }
        try? await Task.sleep(nanoseconds: 120_000_000) // 120ms
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            pinScale = 1.0
        }

        // 2. PFC バーを順番に伸ばす（間隔を狭めてテンポ良く）
        try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            barHeightP = 72 // P（赤）は中程度
        }

        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            barHeightF = 48 // F（黄）は低め
        }

        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            barHeightC = 84 // C（緑）は最も高い
        }

        // 3. テキストをフェードイン
        try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s
        withAnimation(.easeOut(duration: 0.4)) {
            showText = true
        }

        // 最低表示時間を 1.3 秒に保証（現在の sleep 合計 750ms + 追加 550ms）
        try? await Task.sleep(nanoseconds: 550_000_000) // 0.55s
    }
}

// MARK: - MapGridView（背景のマップ風グリッド）

private struct MapGridView: View {
    var body: some View {
        Canvas { context, size in
            // 道路に見立てた白い幹線
            let roads: [(CGFloat, Bool)] = [
                (size.height * 0.25, false),
                (size.height * 0.55, false),
                (size.height * 0.78, false),
                (size.width  * 0.20, true),
                (size.width  * 0.55, true),
                (size.width  * 0.80, true),
            ]
            for (pos, isVertical) in roads {
                context.stroke(
                    Path { p in
                        if isVertical {
                            p.move(to: CGPoint(x: pos, y: 0))
                            p.addLine(to: CGPoint(x: pos, y: size.height))
                        } else {
                            p.move(to: CGPoint(x: 0, y: pos))
                            p.addLine(to: CGPoint(x: size.width, y: pos))
                        }
                    },
                    with: .color(.white.opacity(0.75)),
                    lineWidth: 10
                )
            }

            // 細い格子線
            let gridStep: CGFloat = 44
            let lineColor = Color.white.opacity(0.5)
            for x in stride(from: 0, through: size.width, by: gridStep) {
                context.stroke(
                    Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(lineColor),
                    lineWidth: 0.6
                )
            }
            for y in stride(from: 0, through: size.height, by: gridStep) {
                context.stroke(
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(lineColor),
                    lineWidth: 0.6
                )
            }

            // 緑ブロック（公園）
            context.fill(
                Path(CGRect(x: 0, y: 0, width: size.width * 0.18, height: size.height * 0.22)),
                with: .color(Color(red: 0.72, green: 0.83, blue: 0.74).opacity(0.8))
            )
            context.fill(
                Path(CGRect(x: size.width * 0.57, y: size.height * 0.57, width: size.width * 0.43, height: size.height * 0.20)),
                with: .color(Color(red: 0.72, green: 0.83, blue: 0.74).opacity(0.7))
            )

            // 青ブロック（水域）
            context.fill(
                Path(CGRect(x: size.width * 0.62, y: 0, width: size.width * 0.38, height: size.height * 0.22)),
                with: .color(Color(red: 0.73, green: 0.83, blue: 0.91).opacity(0.8))
            )
        }
    }
}

// MARK: - AppMapPinShape（マップピン形状）


// MARK: - SplashBarView（PFC バー）

private struct SplashBarView: View {
    let color: Color
    let shadowColor: Color
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: 20, height: height)
            .shadow(color: shadowColor, radius: 4, x: 0, y: 3)
    }
}

// MARK: - Preview

#Preview {
    let factory = Factory.create(env: .preview)
    let store = Store(factory: factory)
    return SplashPage(
        model: factory.makeSplashPageModel(store: store),
        isInitialized: .constant(false),
        isTutorialCompleted: .constant(false)
    )
    .environment(\.factory, factory)
    .environment(store)
}
