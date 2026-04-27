import SwiftUI
import PhotosUI

@MainActor
struct ShopItemRowView: View {
    let shop: ShopCatalog
    let item: ShopItem
    
    @Environment(\.factory) private var factory
    @State private var model: ShopItemRowViewModel
    
    init(shop: ShopCatalog, item: ShopItem, model: ShopItemRowViewModel) {
        self.shop = shop
        self.item = item
        self._model = State(wrappedValue: model)
    }
    
    private var categoryIcon: String {
        shop.category.iconName
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Menu Photo
            Group {
                if let photoData = model.itemImageData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if model.isLoadingImage {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 52, height: 52)
                        .overlay {
                            ProgressView()
                                .controlSize(.small)
                        }
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
            }
            .task {
                await model.loadImage(item: item)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                // Shop Name with Category Icon
                HStack(spacing: 4) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 10))
                        .foregroundStyle(.blue.secondary)
                    
                    Text(shop.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Menu Name
                Text(item.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
                
                // Calories + PFC
                HStack(alignment: .center, spacing: 6) {
                    // Calories
                    HStack(alignment: .bottom, spacing: 0.5) {
                        Text("\(Int(item.calorie))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                        Text("kcal")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 0.5)
                    }
                    
                    Text("|")
                        .font(.system(size: 9))
                        .foregroundStyle(.quaternary)
                    
                    // PFC
                    HStack(spacing: 5) {
                        nutrientView(name: "P", value: item.protein, color: .pColor)
                        nutrientView(name: "F", value: item.fat, color: .fColor)
                        nutrientView(name: "C", value: item.carbohydrate, color: .cColor)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            
            Spacer()
            
            // Report Button
            Menu {
                ForEach(ShopItemReportType.allCases, id: \.self) { type in
                    Button {
                        model.selectReportType(type)
                    } label: {
                        Label(type.label, systemImage: type.iconName)
                    }
                }
            } label: {
                Image(systemName: "exclamationmark.bubble")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .frame(width: 32, height: 32)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        .alert("フィードバックを送りますか？", isPresented: $model.showConfirmAlert) {
            Button("キャンセル", role: .cancel) {
                model.resetSelection()
            }
            Button("報告する") {
                Task {
                    await model.report(
                        shopId: shop.id,
                        itemId: item.id
                    )
                }
            }
        } message: {
            VStack(spacing: 12) {
                if let image = model.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("この内容で管理者に報告を送信します。")
            }
        }
        .confirmationDialog("写真の選択方法", isPresented: $model.showSourceSelection, titleVisibility: .visible) {
            Button("カメラで撮影") {
                model.showCamera = true
            }
            Button("ライブラリから選択") {
                model.showPhotoPicker = true
            }
            Button("キャンセル", role: .cancel) { }
        }
        .photosPicker(isPresented: $model.showPhotoPicker, selection: $model.selectedPhotosItem, matching: .images)
        .sheet(isPresented: $model.showCamera) {
            ImagePickerView(isPresented: $model.showCamera, selectedImage: $model.selectedImage, sourceType: .camera)
                .ignoresSafeArea()
                .onDisappear {
                    model.handleCameraResult()
                }
        }
        .alert("報告を受け付けました", isPresented: $model.showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("ご協力ありがとうございます。")
        }
        .alert("エラー", isPresented: Binding(
            get: { model.error != nil },
            set: { _ in model.error = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = model.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func nutrientView(name: String, value: Double, color: Color) -> some View {
        HStack(alignment: .bottom, spacing: 2) {
            Text(name)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
                .padding(.bottom, 0.5)
            
            HStack(alignment: .bottom, spacing: 0.5) {
                Text(String(format: "%.1f", value))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("g")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 0.5)
            }
        }
    }
}

#Preview {
    let factory = Factory.create(env: .preview)
    let shop = ShopCatalog(
        name: "吉野家",
        category: .beefBowl,
        items: []
    )
    
    let item1 = ShopItem(
        name: "牛丼 並盛",
        calorie: 632,
        protein: 20.2,
        fat: 25.1,
        carbohydrate: 77.4
    )
    
    let item2 = ShopItem(
        name: "【期間限定】ねぎ玉牛丼 ギガ盛（たまご・お新香・味噌汁セット付き）",
        calorie: 911,
        protein: 34.5,
        fat: 53.2,
        carbohydrate: 73.1
    )
    
    let item3 = ShopItem(
        name: "非常に長い商品名テスト用のメニュー名です。3行以上になるように調整しています。この部分は表示されないはずです。",
        calorie: 500,
        protein: 20.0,
        fat: 10.0,
        carbohydrate: 80.0
    )
    
    return ScrollView {
        VStack(spacing: 12) {
            ShopItemRowView(
                shop: shop,
                item: item1,
                model: factory.makeShopItemRowViewModel()
            )
            
            ShopItemRowView(
                shop: shop,
                item: item2,
                model: factory.makeShopItemRowViewModel()
            )
            
            ShopItemRowView(
                shop: shop,
                item: item3,
                model: factory.makeShopItemRowViewModel()
            )
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
    .environment(\.factory, factory)
}
