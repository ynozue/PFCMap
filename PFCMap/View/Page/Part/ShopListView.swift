import SwiftUI

@MainActor
struct ShopListView: View {
    let shops: [ShopCatalog]
    var onSelect: (ShopCatalog) -> Void = { _ in }
    @State private var viewModel = ShopListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator to make it look like a sheet
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            if shops.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("表示できる店舗情報がありません")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
                .frame(maxHeight: .infinity)
                .padding(.bottom, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(shops) { shop in
                            ShopRowView(shop: shop)
                                .onTapGesture {
                                    onSelect(shop)
                                }
                            if shop.id != shops.last?.id {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 15, x: 0, y: -5)
    }
}

@MainActor
struct ShopRowView: View {
    let shop: ShopCatalog
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.gradient)
                    .frame(width: 48, height: 48)
                Image(systemName: "fork.knife")
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let firstItem = shop.items.first {
                    HStack(spacing: 8) {
                        Text("\(Int(firstItem.calorie)) kcal")
                        Text("P: \(Int(firstItem.protein))g")
                        Text("F: \(Int(firstItem.fat))g")
                        Text("C: \(Int(firstItem.carbohydrate))g")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
                } else {
                    Text("メニュー情報なし")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.2).ignoresSafeArea()
        ShopListView(shops: [
            ShopCatalog(name: "松屋", items: [.init(name: "牛めし", calorie: 700, protein: 20, fat: 20, carbohydrate: 100)]),
            ShopCatalog(name: "吉野家", items: [.init(name: "牛丼", calorie: 650, protein: 18, fat: 18, carbohydrate: 90)])
        ])
        .frame(height: 250)
    }
}
