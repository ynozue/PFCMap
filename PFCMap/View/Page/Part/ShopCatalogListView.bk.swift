//import SwiftUI
//
//@MainActor
//struct ShopCatalogListView: View {
//    let shops: [ShopCatalog]
//    var onSelect: (ShopCatalog) -> Void = { _ in }
//    var onSelectionChange: (Set<UUID>) -> Void = { _ in }
//    @State private var model = ShopCatalogListViewModel()
//    
//    // 3列のグリッド定義
//    private let columns = [
//        GridItem(.flexible(), spacing: 8),
//        GridItem(.flexible(), spacing: 8),
//        GridItem(.flexible(), spacing: 8)
//    ]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            // Header
//            HStack {
//                Spacer()
//                Button(model.selectedShopIds.isEmpty ? "Select All" : "Clear All") {
//                    if model.selectedShopIds.isEmpty {
//                        model.selectAll(shops: shops)
//                    } else {
//                        model.selectedShopIds.removeAll()
//                    }
//                }
//                .font(.caption.bold())
//                .foregroundStyle(.blue)
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 12)
//            
//            if shops.isEmpty {
//                emptyView
//            } else {
//                ScrollView {
//                    LazyVGrid(columns: columns, spacing: 8) {
//                        ForEach(shops) { shop in
//                            ShopCatalogCardView(
//                                shop: shop,
//                                isSelected: model.isSelected(id: shop.id)
//                            )
//                            .onTapGesture {
//                                model.toggleSelection(id: shop.id)
//                                onSelect(shop)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 16)
//                }
//            }
//        }
//        .task {
//            // 初期表示時に全選択
//            if !shops.isEmpty && model.selectedShopIds.isEmpty {
//                model.selectAll(shops: shops)
//            }
//        }
//        .onChange(of: model.selectedShopIds) { _, newValue in
//            onSelectionChange(newValue)
//        }
//        .onChange(of: shops) { _, newValue in
//            // 初めてデータがロードされた際に全選択
//            if model.selectedShopIds.isEmpty && !newValue.isEmpty {
//                model.selectAll(shops: newValue)
//            }
//        }
//        .liquidGlassBackground(cornerRadius: 24)
//        .padding(.horizontal, 16)
//        .padding(.bottom, 8) // 下部にも少し余白を持たせて浮遊感を出す
//    }
//    
//    @ViewBuilder
//    private var emptyView: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "fork.knife.circle")
//                .font(.title2)
//                .foregroundStyle(.tertiary)
//            Text("店舗情報がありません")
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 100)
//    }
//}
//
//@MainActor
//struct ShopCatalogCardView: View {
//    let shop: ShopCatalog
//    let isSelected: Bool
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 8) {
//            // Icon with Suitability indicator
//            ZStack(alignment: .bottomTrailing) {
//                Circle()
//                    .fill(isSelected ? Color.blue.gradient : Color.gray.opacity(0.08).gradient)
//                    .frame(width: 28, height: 28)
//                
//                Image(systemName: "fork.knife")
//                    .font(.system(size: 11))
//                    .foregroundStyle(isSelected ? .white : .secondary)
//                
//                // Suitability Mark Badge
//                if !shop.suitabilityMark.isEmpty {
//                    Text(shop.suitabilityMark)
//                        .font(.system(size: 9, weight: .bold))
//                        .foregroundStyle(shop.suitabilityMark == "○" ? .green : .orange)
//                        .background {
//                            Circle()
//                                .fill(.white)
//                                .shadow(color: .black.opacity(0.1), radius: 1)
//                        }
//                        .offset(x: 4, y: 4)
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 0) {
//                if !shop.category.isEmpty {
//                    Text(shop.category)
//                        .font(.system(size: 8))
//                        .foregroundStyle(.tertiary)
//                        .textCase(.uppercase)
//                }
//                
//                Text(shop.name)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
//                    .foregroundStyle(isSelected ? .primary : .secondary)
//                    .lineLimit(2)
//                    .multilineTextAlignment(.leading)
//                    .minimumScaleFactor(0.85)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 8)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .frame(height: 52) // 情報を増やしたため少し高さを出す
//        .background {
//            RoundedRectangle(cornerRadius: 12, style: .continuous)
//                .fill(isSelected ? .blue.opacity(0.06) : .secondary.opacity(0.03))
//        }
//        .overlay {
//            RoundedRectangle(cornerRadius: 12, style: .continuous)
//                .stroke(isSelected ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
//        }
//        .scaleEffect(isSelected ? 1.02 : 1.0)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
//    }
//}
//
//
//#Preview {
//    ZStack(alignment: .bottom) {
//        Color.gray.opacity(0.1).ignoresSafeArea()
//        ShopCatalogListView(shops: [
//            ShopCatalog(name: "ガスト", category: "ファミリーレストラン", suitabilityMark: "○"),
//            ShopCatalog(name: "サイゼリヤ", category: "ファミリーレストラン", suitabilityMark: "○"),
//            ShopCatalog(name: "大戸屋", category: "定食", suitabilityMark: "○"),
//            ShopCatalog(name: "吉野家", category: "牛丼・丼もの", suitabilityMark: "○"),
//            ShopCatalog(name: "マクドナルド", category: "ハンバーガー", suitabilityMark: "-")
//        ])
//        .frame(height: 180)
//    }
//}
//
//
