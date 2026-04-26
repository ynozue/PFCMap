import SwiftUI

@MainActor
struct ShopCatalogListView: View {
    let homeModel: HomePageModel
    let maxHeight: CGFloat
    var onSelect: (ShopCatalog) -> Void = { _ in }
    @Environment(\.factory) private var factory
    @State private var model = ShopCatalogListViewModel()
    @State private var dragOffset: CGFloat = 0
    
    private var inRangeShops: [ShopCatalog] {
        model.inRangeShops(
            from: homeModel.shops,
            disabledShopIds: homeModel.disabledShopIds,
            currentLocation: homeModel.currentLocation,
            searchResults: homeModel.searchResults,
            mapDistance: homeModel.mapDistance.rawValue
        )
    }

    private var tabs: [ShopCatalogListViewModel.TabItem] {
        model.tabItems(
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
            VStack(spacing: 0) {
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
                
                // Header
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
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
                    }
                    
                    Spacer()
                    
                    Text("範囲内の店舗 \(inRangeShops.count)件")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                    
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
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50 // スワイプと判定する閾値を小さく設定
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            if model.isExpanded && value.translation.height > threshold {
                                model.isExpanded = false
                            } else if !model.isExpanded && value.translation.height < -threshold {
                                model.isExpanded = true
                            }
                            dragOffset = 0
                        }
                    }
            )
            
            // Tab Bar
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack(spacing: 8) {
                        ForEach(tabs) { tab in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    model.selectedShopId = tab.id
                                }
                            } label: {
                                Text("\(tab.name) (\(tab.count))")
                                    .font(.system(size: 12, weight: model.selectedShopId == tab.id ? .bold : .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(model.selectedShopId == tab.id ? Color.blue.opacity(0.1) : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(model.selectedShopId == tab.id ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                            .foregroundColor(model.selectedShopId == tab.id ? .blue : .primary)
                            .id(tab.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .onChange(of: model.selectedShopId) { _, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }

            if tabs.isEmpty || (tabs.count == 1 && tabs[0].id == nil && tabs[0].count == 0) {
                emptyView
            } else {
                TabView(selection: $model.selectedShopId) {
                    ForEach(tabs) { tab in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                let items = model.displayItemsForTab(
                                    tab: tab,
                                    from: homeModel.shops,
                                    proteinThreshold: homeModel.proteinThreshold,
                                    fatThreshold: homeModel.fatThreshold,
                                    disabledShopIds: homeModel.disabledShopIds,
                                    currentLocation: homeModel.currentLocation,
                                    searchResults: homeModel.searchResults,
                                    mapDistance: homeModel.mapDistance.rawValue
                                )
                                ForEach(items) { displayItem in
                                    ShopItemRowView(
                                        shop: displayItem.shop,
                                        item: displayItem.item,
                                        factory: factory
                                    )
                                    .onTapGesture {
                                        onSelect(displayItem.shop)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                        .tag(tab.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
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
            Text(inRangeShops.isEmpty ? "範囲内に該当する店舗がありません" : "該当するメニューがありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.1).ignoresSafeArea()
        ShopCatalogListView(homeModel: HomePageModel(), maxHeight: 600)
        .frame(height: 400)
    }
}


