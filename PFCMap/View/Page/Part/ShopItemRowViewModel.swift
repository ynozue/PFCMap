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

    private let repository: any ShopCatalogRepository
    
    init(repository: any ShopCatalogRepository) {
        self.repository = repository
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
