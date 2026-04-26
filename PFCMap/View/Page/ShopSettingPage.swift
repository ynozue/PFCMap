import SwiftUI

@MainActor
struct ShopSettingPage: View {
    @Environment(\.factory) private var factory
    @State private var model: ShopSettingPageModel
    
    init(factory: Factory) {
        self._model = State(wrappedValue: factory.makeShopSettingPageModel())
    }
    
    var body: some View {
        List {
            Section {
                ForEach(model.shops) { shop in
                    Toggle(isOn: Binding(
                        get: { model.isShopEnabled(shopId: shop.id) },
                        set: { _ in model.toggleShopSetting(shopId: shop.id) }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(shop.name)
                                .font(.headline)
                            Text(shop.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("表示対象のショップを選択")
            } footer: {
                Text("オフにしたショップはマップおよびリストに表示されなくなります。")
            }
        }
        .navigationTitle("表示ショップ設定")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await model.onAppear() }
        }
    }
}

#Preview {
    let factory = Factory.create(env: .preview)
    return NavigationStack {
        ShopSettingPage(factory: factory)
            .environment(\.factory, factory)
    }
}
