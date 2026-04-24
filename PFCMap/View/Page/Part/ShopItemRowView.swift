import SwiftUI
import PhotosUI

@MainActor
struct ShopItemRowView: View {
    let shop: ShopCatalog
    let item: ShopItem
    
    @Environment(\.factory) private var factory
    @State private var model = ShopItemRowViewModel()
    @State private var showSuccessAlert = false
    @State private var showConfirmAlert = false
    @State private var selectedReportType: ShopItemReportType?
    
    // Photo selection states
    @State private var showSourceSelection = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedPhotosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    private var categoryIcon: String {
        shop.category.iconName
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Menu Photo
            if let photoData = item.photoData, let image = UIImage(data: photoData) {
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
                    
                    Text(shop.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Menu Name
                Text(item.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
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
                        nutrientView(name: "P", value: item.protein, color: .orange)
                        nutrientView(name: "F", value: item.fat, color: .yellow)
                        nutrientView(name: "C", value: item.carbohydrate, color: .green)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            
            Spacer()
            
            // Report Button
            Menu {
                ForEach(ShopItemReportType.allCases, id: \.self) { type in
                    Button {
                        if type == .photoUpload {
                            showSourceSelection = true
                        } else {
                            selectedReportType = type
                            showConfirmAlert = true
                        }
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
        .alert("フィードバックを送りますか？", isPresented: $showConfirmAlert) {
            Button("キャンセル", role: .cancel) {
                selectedReportType = nil
                selectedImage = nil
                selectedPhotosItem = nil
            }
            Button("報告する") {
                if let type = selectedReportType {
                    Task {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        await model.report(
                            shopId: shop.id,
                            itemId: item.id,
                            type: type,
                            imageData: imageData,
                            repository: factory.makeShopCatalogRepository()
                        )
                        if model.error == nil {
                            showSuccessAlert = true
                            selectedImage = nil
                            selectedPhotosItem = nil
                        }
                    }
                }
            }
        } message: {
            VStack(spacing: 12) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("この内容で管理者に報告を送信します。")
            }
        }
        .confirmationDialog("写真の選択方法", isPresented: $showSourceSelection, titleVisibility: .visible) {
            Button("カメラで撮影") {
                showCamera = true
            }
            Button("ライブラリから選択") {
                showPhotoPicker = true
            }
            Button("キャンセル", role: .cancel) { }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotosItem, matching: .images)
        .onChange(of: selectedPhotosItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    selectedReportType = .photoUpload
                    showConfirmAlert = true
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePickerView(isPresented: $showCamera, selectedImage: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
                .onDisappear {
                    if selectedImage != nil {
                        selectedReportType = .photoUpload
                        showConfirmAlert = true
                    }
                }
        }
        .alert("報告を受け付けました", isPresented: $showSuccessAlert) {
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
        HStack(spacing: 1) {
            Text(name)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text(String(format: "%.1fg", value))
                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let item = ShopItem(
        name: "牛丼 並盛",
        calorie: 632,
        protein: 20.2,
        fat: 25.1,
        carbohydrate: 77.4
    )
    let shop = ShopCatalog(
        name: "吉野家",
        category: .beefBowl,
        items: [item]
    )
    
    return ShopItemRowView(shop: shop, item: item)
        .environment(\.factory, .create(env: .preview))
        .padding()
}
