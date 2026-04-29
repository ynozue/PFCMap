import SwiftUI

@MainActor
struct MenuPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.factory) private var factory
    @State private var model: MenuPageModel
    
    init(model: MenuPageModel) {
        self._model = State(wrappedValue: model)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        AppLogoView(size: 80)
                            .padding(.top, 10)
                        
                        Text("PFCMap")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section("設定") {
                    HStack {
                        Label("最終同期日時", systemImage: "arrow.clockwise")
                        Spacer()
                        Text(model.lastSyncDateString(date: model.lastFetchedAt))
                            .font(.system(.footnote, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        ShopSettingPage(model: factory.makeShopSettingPageModel())
                    } label: {
                        Label("表示ショップ設定", systemImage: "list.bullet.rectangle")
                    }
                }
                
                Section("Appについて") {
                    HStack {
                        Label("バージョン", systemImage: "info.circle")
                        Spacer()
                        Text(model.appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        model.privacyPolicyURL = URL(string: "https://noz.app/pfcmap/privacy.html")
                    } label: {
                        HStack {
                            Label("プライバシーポリシー", systemImage: "hand.raised")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.quaternary)
                        }
                    }
                }
                
#if DEBUG
                Section("デバッグメニュー") {
                    Button {
                        Task { await model.syncAPI() }
                    } label: {
                        Label("API同期", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button {
                        Task { await model.generateDBData() }
                    } label: {
                        Label("DB情報の生成", systemImage: "plus.square.on.square")
                    }
                    
                    Button(role: .destructive) {
                        Task { await model.deleteLastSyncDate() }
                    } label: {
                        Label("最終同期日時を削除", systemImage: "trash")
                    }
                    
                    Button(role: .destructive) {
                        Task { await model.deleteTutorialFlag() }
                    } label: {
                        Label("チュートリアル完了フラグを削除", systemImage: "flag.slash")
                    }
                    
                    Button(role: .destructive) {
                        Task { await model.clearDB() }
                    } label: {
                        Label("DBをクリア", systemImage: "trash.circle")
                    }
                    
                    Button(role: .destructive) {
                        model.triggerCrash()
                    } label: {
                        Label("アプリクラッシュ", systemImage: "exclamationmark.triangle")
                    }
                }
#endif
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .padding(8)
                            .background(.quaternary, in: Circle())
                    }
                }
            }
            .onAppear {
                Task { await model.onAppear() }
            }
            .fullScreenCover(item: Binding(
                get: { model.privacyPolicyURL.map { IdentifiableURL(url: $0) } },
                set: { model.privacyPolicyURL = $0?.url }
            )) { identifiableURL in
                SafariView(url: identifiableURL.url)
                    .ignoresSafeArea()
            }
        }
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

#Preview {
    let factory = Factory.create(env: .preview)
    return MenuPage(model: factory.makeMenuPageModel())
        .environment(\.factory, factory)
}
