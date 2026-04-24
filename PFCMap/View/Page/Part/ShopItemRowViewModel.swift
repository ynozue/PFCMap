import Foundation
import Observation

@MainActor
@Observable
final class ShopItemRowViewModel {
    var isReporting: Bool = false
    var error: Error?
    
    func report(shopId: UUID, itemId: UUID, type: ShopItemReportType, imageData: Data?, repository: any ShopCatalogRepository) async {
        isReporting = true
        defer { isReporting = false }
        
        do {
            try await repository.reportItem(shopId: shopId, itemId: itemId, type: type, imageData: imageData)
            // Success handling (e.g. showing a success message if needed)
        } catch {
            self.error = error
        }
    }
}
