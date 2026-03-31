import SwiftUI

@MainActor
struct ShopDetailPage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model: ShopDetailPageModel
    
    init(shop: ShopCatalog) {
        _model = State(wrappedValue: ShopDetailPageModel(shop: shop))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: model.shop.category.iconName)
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text(model.shop.name)
                        .font(.title2.bold())
                }
                
                if !model.shop.description.isEmpty {
                    Text(model.shop.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Active Filters Summary
                HStack(spacing: 8) {
                    filterBadge(label: "P ≥ \(store.settingsStore.proteinThreshold.label)", color: .orange)
                    filterBadge(label: "F ≤ \(store.settingsStore.fatThreshold.label)", color: .yellow)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Items List
            let displayItems = model.displayItems(
                proteinThreshold: store.settingsStore.proteinThreshold,
                fatThreshold: store.settingsStore.fatThreshold
            )
            
            if displayItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "circle.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(.quaternary)
                    Text("条件に合うメニューがありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(displayItems) { item in
                            ShopItemRowView(shop: model.shop, item: item)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func filterBadge(label: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    ShopDetailPage(shop: ShopCatalog(
        name: "ガスト",
        category: .familyRestaurant,
        description: "お手頃価格で楽しめるファミレス",
        items: [
            ShopItem(name: "チーズINハンバーグ", calorie: 750, protein: 35.2, fat: 45.1, carbohydrate: 28.5),
            ShopItem(name: "蒸し鶏のエコスラッド", calorie: 120, protein: 12.5, fat: 3.2, carbohydrate: 5.1)
        ]
    ))
    .environment(PFCMapStore(factory: .create(env: .preview)))
}
