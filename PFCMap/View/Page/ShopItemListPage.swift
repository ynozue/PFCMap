import SwiftUI

@MainActor
struct ShopItemListPage: View {
    @Environment(\.dismiss) private var dismiss
    private let model: ShopItemListPageModel
    
    init(shop: ShopCatalog) {
        self.model = ShopItemListPageModel(shop: shop)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(model.shop.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        
                        Text(model.shop.name)
                            .font(.title.bold())
                        
                        if !model.shop.description.isEmpty {
                            Text(model.shop.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                Section("Items") {
                    if model.shop.items.isEmpty {
                        Text("No items found.")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(model.shop.items) { item in
                            ShopItemRowView(item: item)
                        }
                    }
                }
            }
            .navigationTitle("Shop Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@MainActor
struct ShopItemRowView: View {
    let item: ShopItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Photo placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Label("\(Int(item.calorie)) kcal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    
                    HStack(spacing: 4) {
                        PFCBadge(label: "P", value: item.protein, color: .red)
                        PFCBadge(label: "F", value: item.fat, color: .yellow)
                        PFCBadge(label: "C", value: item.carbohydrate, color: .blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

@MainActor
struct PFCBadge: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .padding(2)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            Text("\(Int(value))g")
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(color)
    }
}

#Preview {
    ShopItemListPage(shop: ShopCatalog(
        name: "ガスト",
        category: "ファミリーレストラン",
        description: "低価格で美味しいハンバーグが人気。",
        items: [
            ShopItem(name: "チーズINハンバーグ", calorie: 700, protein: 30, fat: 45, carbohydrate: 25),
            ShopItem(name: "たっぷりマヨコーンピザ", calorie: 900, protein: 25, fat: 40, carbohydrate: 110)
        ]
    ))
}
