import SwiftUI

// MARK: - TutorialPage

@MainActor
struct TutorialPage: View {
    @Environment(\.factory) private var factory
    @Binding var isTutorialCompleted: Bool
    @State private var model: TutorialPageModel
    @State private var selectedTab = 0

    init(model: TutorialPageModel, isTutorialCompleted: Binding<Bool>) {
        self._isTutorialCompleted = isTutorialCompleted
        self._model = State(wrappedValue: model)
    }

    var body: some View {
        ZStack {
            // ── 背景（アイコン背景色）────────
            Color(red: 0.92, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            // ── マップ風グリッド背景 ──────────
            TutorialMapGridView()
                .ignoresSafeArea()

            // ── ページコンテンツ ──────────────
            TabView(selection: $selectedTab) {
                TutorialStep1View(selectedTab: $selectedTab)
                    .tag(0)

                TutorialStep2View(model: model, selectedTab: $selectedTab)
                    .tag(1)

                TutorialStep3View(model: model, isTutorialCompleted: $isTutorialCompleted)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onAppear {
                // ページインジケーターをグレー系に
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(white: 0.35, alpha: 1)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(white: 0.35, alpha: 0.3)
            }
        }
        .onAppear {
            Task { await model.onAppear() }
        }
    }
}

// MARK: - ステップ1：ようこそ

@MainActor
private struct TutorialStep1View: View {
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // アプリロゴ
            AppLogoView(size: 140)

            // アプリ名・説明テキスト
            VStack(spacing: 10) {
                Text("PFCMapへようこそ！")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(white: 0.15))

                Text("周辺の飲食店を検索し、\n高タンパク・低脂質なメニューを\n見つけることができます。")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(white: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 28)
            .padding(.horizontal, 36)

            Spacer()

            // 次へボタン
            TutorialPrimaryButton(title: "次へ") {
                withAnimation { selectedTab = 1 }
            }
            .padding(.bottom, 64)
        }
    }
}

// MARK: - ステップ2：お店の選択

@MainActor
private struct TutorialStep2View: View {
    var model: TutorialPageModel
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            // ── ヘッダー ──────────────────────
            VStack(spacing: 8) {
                Text("検索対象のお店")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(white: 0.15))
                    .padding(.top, 52)

                Text("よく利用するお店を選択してください。\n後からでも変更できます。")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(white: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 36)
            }

            // ── リスト ──────────────────────
            if model.isFetchingShops {
                Spacer()
                ProgressView()
                    .tint(Color(white: 0.5))
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(model.shops, id: \.id) { shop in
                            TutorialShopRow(
                                name: shop.name,
                                isEnabled: !model.disabledShopIds.contains(shop.id),
                                onTap: { model.toggleShop(shop) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
            }

            // ── 次へボタン ──────────────────────
            TutorialPrimaryButton(title: "次へ") {
                Task {
                    await model.saveDisabledShops()
                    withAnimation { selectedTab = 2 }
                }
            }
            .padding(.bottom, 64)
        }
    }
}

// MARK: - ステップ3：位置情報

@MainActor
private struct TutorialStep3View: View {
    var model: TutorialPageModel
    @Binding var isTutorialCompleted: Bool

    /// 位置情報許可ボタンをタップしたかどうか
    @State private var didRequestPermission = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // ── アイコン ──────────────────────
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 80, height: 80)
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .foregroundStyle(Color.cColor)
            }

            // ── テキスト ──────────────────────
            VStack(spacing: 10) {
                Text("位置情報の利用")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(white: 0.15))

                Text("現在地の周辺にあるお店を検索するために、\n位置情報を利用します。")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(white: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 24)
            .padding(.horizontal, 36)

            Spacer()

            // ── 位置情報許可ボタン ──────────────
            // 許可済みの場合はグレーアウト
            Button {
                Task {
                    await model.requestLocationPermission()
                    didRequestPermission = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: didRequestPermission ? "checkmark" : "location.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(didRequestPermission ? "連携完了" : "次へ")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(didRequestPermission ? Color(white: 0.55) : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(didRequestPermission ? Color(white: 0.88) : Color.cColor)
                )
                .padding(.horizontal, 28)
            }
            .disabled(didRequestPermission)
            .animation(.easeInOut(duration: 0.2), value: didRequestPermission)

            // ── はじめるボタン（許可後に表示）──────────
            if didRequestPermission {
                TutorialPrimaryButton(title: "はじめる") {
                    Task {
                        await model.completeTutorial(isTutorialCompleted: $isTutorialCompleted)
                    }
                }
                .padding(.top, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: 64)
        }
        .animation(.easeOut(duration: 0.3), value: didRequestPermission)
    }
}

// MARK: - 共通パーツ：プライマリボタン

@MainActor
private struct TutorialPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(white: 0.2))
                )
                .padding(.horizontal, 28)
        }
    }
}

// MARK: - 共通パーツ：お店行

@MainActor
private struct TutorialShopRow: View {
    let name: String
    let isEnabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // チェックマーク
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isEnabled ? Color.cColor : Color(white: 0.7))
                    .animation(.easeInOut(duration: 0.15), value: isEnabled)

                Text(name)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(white: 0.2))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.8))
            )
        }
    }
}

// MARK: - TutorialMapGridView（背景のマップ風グリッド）

private struct TutorialMapGridView: View {
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

// MARK: - Preview

#Preview {
    let factory = Factory.create(env: .preview)
    return TutorialPage(model: factory.makeTutorialPageModel(), isTutorialCompleted: .constant(false))
        .environment(\.factory, factory)
}
