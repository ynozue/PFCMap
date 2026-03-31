import SwiftUI

@MainActor
struct HomePage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = HomePageModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                headerView
                
                // Main List Content
                ShopCatalogListView(
                    shops: store.shopCatalogStore.shops,
                    onSelect: { shop in
                        store.selectedCatalog = shop
                    },
                    onSelectionChange: { _ in
                        // 必要に応じてStoreの状態を同期
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background {
                // モダンな背景グラデーション
                ZStack {
                    Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                    
                    Circle()
                        .fill(Color.blue.opacity(0.05))
                        .frame(width: 400, height: 400)
                        .blur(radius: 60)
                        .offset(x: -150, y: -300)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .blur(radius: 50)
                        .offset(x: 180, y: 150)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: Binding(get: { model.isMenuShowing }, set: { model.isMenuShowing = $0 })) {
                MenuPage()
            }
            .sheet(item: Binding<ShopCatalog?>(
                get: { store.selectedCatalog },
                set: { store.selectedCatalog = $0 }
            )) { shop in
                ShopItemListPage(shop: shop)
            }
            .navigationDestination(isPresented: $model.isMapShowing) {
                MapPage()
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("PFCMap")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Select your favorite shop")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Map Navigation Button
                Button {
                    model.isMapShowing = true
                } label: {
                    Image(systemName: "map.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.blue.gradient)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                
                // Menu Button
                Button {
                    model.isMenuShowing = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18))
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}

#Preview {
    HomePage()
        .environment(PFCMapStore(factory: .create(env: .preview)))
}
