import SwiftUI

@MainActor
struct SplashPage: View {
    @Environment(\.factory) private var factory
    @Binding var isInitialized: Bool
    @State private var model = SplashPageModel()
    @State private var animationInProgress = false
    
    var body: some View {
        ZStack {
            // 背景のグラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.3, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // ロゴアイコン
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .scaleEffect(animationInProgress ? 1.0 : 0.8)
                        .opacity(animationInProgress ? 1.0 : 0.0)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.white)
                        .scaleEffect(animationInProgress ? 1.0 : 0.5)
                        .opacity(animationInProgress ? 1.0 : 0.0)
                }
                
                // アプリタイトル
                VStack(spacing: 8) {
                    Text("PFCMap")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Macro Balanced Map")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .offset(y: animationInProgress ? 0 : 20)
                        .opacity(animationInProgress ? 1.0 : 0.0)
                }
                
                Spacer()
                    .frame(height: 50)
                
                // 読み込み中表示
                VStack {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                    
                    Text("Loading initial data...")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.top, 10)
                }
                .opacity(animationInProgress ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.4)) {
                animationInProgress = true
            }
            
            Task {
                // 少しだけ意図的に遅延させてロゴを見せる
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await model.onAppear(factory: factory, isInitialized: $isInitialized)
            }
        }
        .alert("エラー", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("再試行") {
                Task {
                    await model.onAppear(factory: factory, isInitialized: $isInitialized)
                }
            }
        } message: {
            if let errorMessage = model.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    SplashPage(isInitialized: .constant(false))
        .environment(\.factory, Factory.create(env: .preview))
}
