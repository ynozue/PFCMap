import SwiftUI

@MainActor
struct ShopSettingPage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = ShopSettingPageModel()
    
    var body: some View {
        List {
            Section {
                ForEach(store.shopCatalogStore.shops) { shop in
                    Toggle(isOn: Binding(
                        get: { model.isShopEnabled(shopId: shop.id, store: store) },
                        set: { _ in model.toggleShopSetting(shopId: shop.id, store: store) }
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
    }
}

#Preview {
    NavigationStack {
        ShopSettingPage()
            .environment(PFCMapStore(factory: .create(env: .preview)))
    }
}
