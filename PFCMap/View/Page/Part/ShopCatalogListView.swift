import SwiftUI

@MainActor
struct ShopCatalogListView: View {
    let shops: [ShopCatalog]
    let maxHeight: CGFloat
    var onSelect: (ShopCatalog) -> Void = { _ in }
    @State private var model = ShopCatalogListViewModel()
    
    private var sortedItems: [ShopCatalogListViewModel.DisplayItem] {
        model.displayItems(from: shops)
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
            HStack {
                Text("メニューリスト")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
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
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(model.sortType.rawValue)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
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
                            ShopItemRowView(displayItem: displayItem)
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

@MainActor
struct ShopItemRowView: View {
    let displayItem: ShopCatalogListViewModel.DisplayItem
    
    private var categoryIcon: String {
        displayItem.shop.category.iconName
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Menu Photo
            if let photoData = displayItem.item.photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 18))
                            .foregroundStyle(.tertiary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                // Shop Name with Category Icon
                HStack(spacing: 4) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 10))
                        .foregroundStyle(.blue.secondary)
                    
                    Text(displayItem.shop.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Menu Name
                Text(displayItem.item.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
                
                // Calories + PFC
                HStack(alignment: .center, spacing: 6) {
                    // Calories
                    HStack(alignment: .bottom, spacing: 0.5) {
                        Text("\(Int(displayItem.item.calorie))")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                        Text("kcal")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 0.5)
                    }
                    
                    Text("|")
                        .font(.system(size: 9))
                        .foregroundStyle(.quaternary)
                    
                    // PFC
                    HStack(spacing: 5) {
                        nutrientView(name: "P", value: displayItem.item.protein, color: .orange)
                        nutrientView(name: "F", value: displayItem.item.fat, color: .yellow)
                        nutrientView(name: "C", value: displayItem.item.carbohydrate, color: .green)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private func nutrientView(name: String, value: Double, color: Color) -> some View {
        HStack(spacing: 1) {
            Text(name)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(color)
            Text(String(format: "%.1fg", value))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
        }
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


