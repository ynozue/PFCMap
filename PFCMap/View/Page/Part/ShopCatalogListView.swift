import SwiftUI

@MainActor
struct ShopCatalogListView: View {
    let shops: [ShopCatalog]
    let maxHeight: CGFloat
    var onSelect: (ShopCatalog) -> Void = { _ in }
    @Environment(PFCMapStore.self) private var store
    @State private var model = ShopCatalogListViewModel()
    
    private var sortedItems: [ShopCatalogListViewModel.DisplayItem] {
        model.displayItems(
            from: shops,
            proteinThreshold: store.settingsStore.proteinThreshold,
            fatThreshold: store.settingsStore.fatThreshold,
            disabledShopIds: store.settingsStore.disabledShopIds
        )
    }
    
    // 現在の高さ（計算値）
    private var currentHeight: CGFloat {
        model.isExpanded ? maxHeight * 0.85 : maxHeight * 0.3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Drag Handle
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height < -50 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                model.isExpanded = true
                            }
                        } else if value.translation.height > 50 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                model.isExpanded = false
                            }
                        }
                    }
            )
            
            // Header
            HStack(spacing: 8) {
                // Protein Filter Toggle
                Menu {
                    Picker("Protein 閾値", selection: Binding(
                        get: { store.settingsStore.proteinThreshold },
                        set: { store.settingsStore.updateProteinThreshold($0) }
                    )) {
                        ForEach(ProteinThreshold.allCases, id: \.self) { threshold in
                            Text(threshold.label).tag(threshold)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("P≥\(store.settingsStore.proteinThreshold.label)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background(Color.orange)
                    .clipShape(Capsule())
                }
                
                // Fat Filter Toggle
                Menu {
                    Picker("Fat 閾値", selection: Binding(
                        get: { store.settingsStore.fatThreshold },
                        set: { store.settingsStore.updateFatThreshold($0) }
                    )) {
                        ForEach(FatThreshold.allCases, id: \.self) { threshold in
                            Text(threshold.label).tag(threshold)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("F≤\(store.settingsStore.fatThreshold.label)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background(Color.yellow)
                    .clipShape(Capsule())
                }
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        model.isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: model.isExpanded ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue.secondary)
                }
                
                Spacer()
                
                Menu {
                    Picker("ソート順", selection: $model.sortType) {
                        ForEach(ShopCatalogListViewModel.SortType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down.circle")
                        Text(model.sortType.rawValue)
                    }
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            if shops.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedItems) { displayItem in
                            ShopItemRowView(shop: displayItem.shop, item: displayItem.item)
                                .onTapGesture {
                                    onSelect(displayItem.shop)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(height: currentHeight, alignment: .top)
        .liquidGlassBackground(cornerRadius: 24)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife.circle")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("店舗情報がありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}


#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.1).ignoresSafeArea()
        ShopCatalogListView(shops: [
            ShopCatalog(
                name: "ガスト",
                category: .familyRestaurant,
                items: [
                    ShopItem(name: "チーズINハンバーグ", calorie: 750, protein: 35.2, fat: 45.1, carbohydrate: 28.5),
                    ShopItem(name: "蒸し鶏のエコスラッド", calorie: 120, protein: 12.5, fat: 3.2, carbohydrate: 5.1)
                ]
            ),
            ShopCatalog(
                name: "大戸屋",
                category: .setMeal,
                items: [
                    ShopItem(name: "しまほっけの炭火焼き定食", calorie: 580, protein: 42.1, fat: 12.5, carbohydrate: 65.2)
                ]
            )
        ], maxHeight: 600)
        .frame(height: 400)
    }
}


