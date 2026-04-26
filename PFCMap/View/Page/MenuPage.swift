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
                Section("設定") {
                    HStack {
                        Label("最終同期日時", systemImage: "arrow.clockwise")
                        Spacer()
                        Text(model.lastSyncDateString(date: model.lastFetchedAt))
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
                    
                    NavigationLink {
                        Text("利用規約（未実装）")
                    } label: {
                        Label("利用規約", systemImage: "doc.text")
                    }
                    
                    NavigationLink {
                        Text("プライバシーポリシー（未実装）")
                    } label: {
                        Label("プライバシーポリシー", systemImage: "hand.raised")
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
            .navigationTitle("メニュー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                Task { await model.onAppear() }
            }
        }
    }
}

#Preview {
    let factory = Factory.create(env: .preview)
    return MenuPage(model: factory.makeMenuPageModel())
        .environment(\.factory, factory)
}
