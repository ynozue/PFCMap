import Foundation

protocol ImageRepository: Sendable {
    /// 画像をリモートから取得する
    /// 永続化は呼び出し側が ShopCatalogRepository.updatePhotoData で行う
    /// - Parameter url: 画像のURL
    /// - Returns: 画像データ
    func fetchImage(url: URL) async throws -> Data
}
