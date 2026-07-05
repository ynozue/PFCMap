import Foundation
import _PhotosUI_SwiftUI
import Observation
import PhotosUI
import UIKit

@MainActor
@Observable
final class ShopItemRowViewModel {
    var isReporting: Bool = false
    var error: Error?
    
    // UI states
    var showSuccessAlert = false
    var showConfirmAlert = false
    var selectedReportType: ShopItemReportType?
    
    // Photo selection states
    var showSourceSelection = false
    var showPhotoPicker = false
    var showCamera = false
    var selectedPhotosItem: PhotosPickerItem? {
        didSet {
            handlePhotosItemChange()
        }
    }
    var selectedImage: UIImage?
    
    // Image loading states
    var itemImageData: Data?
    var isLoadingImage = false
    var imageError: Error?

    private let repository: any ShopCatalogRepository
    private let imageRepository: any ImageRepository
    
    init(repository: any ShopCatalogRepository, imageRepository: any ImageRepository) {
        self.repository = repository
        self.imageRepository = imageRepository
    }
    
    func loadImage(item: ShopItem) async {
        // すでにデータがある場合はそれを使う
        if let data = item.photoData {
            self.itemImageData = data
            return
        }
        
        // URLがない場合は終了
        guard let urlString = item.photoURL, let url = URL(string: urlString) else {
            return
        }
        
        // すでに読み込み済み、または読み込み中の場合は終了
        if itemImageData != nil || isLoadingImage {
            return
        }
        
        isLoadingImage = true
        defer { isLoadingImage = false }
        
        do {
            let data = try await imageRepository.fetchImage(url: url)
            self.itemImageData = data
            // データベースに画像データを永続化
            try await repository.updatePhotoData(itemId: item.id, data: data)
        } catch {
            self.imageError = error
            print("Failed to load image: \(error)")
        }
    }
    
    func report(shopId: UUID, itemId: UUID) async {
        guard let type = selectedReportType else { return }
        
        isReporting = true
        defer { isReporting = false }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        do {
            try await repository.reportItem(shopId: shopId, itemId: itemId, type: type, imageData: imageData)
            showSuccessAlert = true
            resetSelection()
        } catch {
            self.error = error
        }
    }
    
    func resetSelection() {
        selectedReportType = nil
        selectedImage = nil
        selectedPhotosItem = nil
    }
    
    func selectReportType(_ type: ShopItemReportType) {
        if type == .photoUpload {
            showSourceSelection = true
        } else {
            selectedReportType = type
            showConfirmAlert = true
        }
    }
    
    func handleCameraResult() {
        if selectedImage != nil {
            selectedReportType = .photoUpload
            showConfirmAlert = true
        }
    }
    
    private func handlePhotosItemChange() {
        guard let item = selectedPhotosItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                selectedReportType = .photoUpload
                showConfirmAlert = true
            }
        }
    }
}
