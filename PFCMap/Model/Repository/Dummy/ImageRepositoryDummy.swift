import Foundation
import UIKit

actor ImageRepositoryDummy: ImageRepository {
    func fetchImage(url: URL) async throws -> Data {
        // 開発・プレビュー用にダミーデータを返す
        // 本来は本物のURLから取得しても良いが、ここではシステムのアイコンをデータ化して返す例
        if let image = UIImage(systemName: "photo") {
            return image.pngData() ?? Data()
        }
        return Data()
    }
}
