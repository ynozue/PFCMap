import SwiftUI

@MainActor
struct ShopCatalogListView: View {
    let homeModel: HomePageModel
    let maxHeight: CGFloat
    var onSelect: (ShopCatalog) -> Void = { _ in }
    @Environment(\.factory) private var factory
    @State private var model = ShopCatalogListViewModel()
    @State private var dragOffset: CGFloat = 0
    
    private var sortedItems: [ShopCatalogListViewModel.DisplayItem] {
        model.displayItems(
            from: homeModel.shops,
            proteinThreshold: homeModel.proteinThreshold,
            fatThreshold: homeModel.fatThreshold,
            disabledShopIds: homeModel.disabledShopIds,
            currentLocation: homeModel.currentLocation,
            searchResults: homeModel.searchResults,
            mapDistance: homeModel.mapDistance.rawValue
        )
    }
    
    private var baseHeight: CGFloat {
        model.isExpanded ? maxHeight * 0.85 : maxHeight * 0.3
    }
    
    // 現在の高さ（計算値）
    private var currentHeight: CGFloat {
        let proposed = baseHeight - dragOffset
        return min(max(proposed, maxHeight * 0.3), maxHeight * 0.85)
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
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let finalHeight = baseHeight - value.translation.height
                        let midHeight = maxHeight * 0.575 // (0.85 + 0.3) / 2
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            model.isExpanded = finalHeight > midHeight
                            dragOffset = 0
                        }
                    }
            )
            
            // Header
            HStack(spacing: 8) {
                // Protein Filter Toggle
                Menu {
                    Picker("Protein 閾値", selection: Binding(
                        get: { homeModel.proteinThreshold },
                        set: { homeModel.updateProteinThreshold(threshold: $0, factory: factory) }
                    )) {
                        ForEach(ProteinThreshold.allCases, id: \.self) { threshold in
                            Text(threshold.label).tag(threshold)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("P≥\(homeModel.proteinThreshold.label)")
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
                        get: { homeModel.fatThreshold },
                        set: { homeModel.updateFatThreshold(threshold: $0, factory: factory) }
                    )) {
                        ForEach(FatThreshold.allCases, id: \.self) { threshold in
                            Text(threshold.label).tag(threshold)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("F≤\(homeModel.fatThreshold.label)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background(Color.yellow)
                    .clipShape(Capsule())
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
            
            if homeModel.shops.isEmpty {
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
        ShopCatalogListView(homeModel: HomePageModel(), maxHeight: 600)
        .frame(height: 400)
    }
}


