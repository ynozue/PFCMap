import SwiftUI

@MainActor
struct ShopCatalogListView: View {
    let shops: [ShopCatalog]
    var onSelect: (ShopCatalog) -> Void = { _ in }
    @State private var model = ShopCatalogListViewModel()
    
    // 3列のグリッド定義
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Spacer()
                Button(model.selectedShopIds.isEmpty ? "Select All" : "Clear All") {
                    if model.selectedShopIds.isEmpty {
                        model.selectAll(shops: shops)
                    } else {
                        model.selectedShopIds.removeAll()
                    }
                }
                .font(.caption.bold())
                .foregroundStyle(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            if shops.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(shops) { shop in
                            ShopCatalogCardView(
                                shop: shop,
                                isSelected: model.isSelected(id: shop.id)
                            )
                            .onTapGesture {
                                model.toggleSelection(id: shop.id)
                                onSelect(shop)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .task {
            // 初期表示時に全選択
            if !shops.isEmpty && model.selectedShopIds.isEmpty {
                model.selectAll(shops: shops)
            }
        }
        .onChange(of: shops) { _, newValue in
            // 初めてデータがロードされた際に全選択
            if model.selectedShopIds.isEmpty && !newValue.isEmpty {
                model.selectAll(shops: newValue)
            }
        }
        .background(.background)

        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife.circle")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("店舗情報がありません")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }
}

@MainActor
struct ShopCatalogCardView: View {
    let shop: ShopCatalog
    let isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // Smaller Icon
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue.gradient : Color.gray.opacity(0.08).gradient)
                    .frame(width: 24, height: 24)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            
            // Name (Up to 2 lines)
            Text(shop.name)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48) // 高さを固定してグリッドの揃えを綺麗にする
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? .blue.opacity(0.06) : .secondary.opacity(0.03))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}


#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.1).ignoresSafeArea()
        ShopCatalogListView(shops: [
            ShopCatalog(id: "1", name: "ガスト", items: []),
            ShopCatalog(id: "2", name: "サイゼリヤ", items: []),
            ShopCatalog(id: "3", name: "大戸屋", items: []),
            ShopCatalog(id: "4", name: "吉野家", items: []),
            ShopCatalog(id: "5", name: "すき家", items: []),
            ShopCatalog(id: "6", name: "松屋", items: []),
            ShopCatalog(id: "7", name: "モスバーガー", items: []),
            ShopCatalog(id: "8", name: "サブウェイ", items: [])
        ])
        .frame(height: 180)
    }
}


