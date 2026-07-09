import Foundation

struct ShopItem: Sendable, Identifiable, Equatable {
    /// 主食メニューを表す type 値（マップ検索・リスト表示の対象）
    static let stapleFoodType = "主食"

    let id: UUID
    let name: String
    let calorie: Double
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    let type: String
    let url: String?
    let photoURL: String?
    let photoData: Data?
    let createdAt: Date
    let updatedAt: Date
    let deleted: Bool
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        calorie: Double,
        protein: Double,
        fat: Double,
        carbohydrate: Double,
        type: String = "",
        url: String? = nil,
        photoURL: String? = nil,
        photoData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.calorie = calorie
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
        self.type = type
        self.url = url
        self.photoURL = photoURL
        self.photoData = photoData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}
