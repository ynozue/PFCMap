import Foundation

protocol ImageRepository: Sendable {
    /// 画像を取得する（キャッシュがあればキャッシュから、なければリモートから取得してキャッシュする）
    /// - Parameter url: 画像のURL
    /// - Returns: 画像データ
    func fetchImage(url: URL) async throws -> Data
}
