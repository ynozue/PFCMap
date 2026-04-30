import Foundation

public enum ShopItemReportType: String, Sendable, CaseIterable {
    case photoUpload = "写真のアップロード"
    case menuNotExists = "メニューが存在しない"
    case pfcError = "メニューのカロリーPFCに誤りがある"
    
    public var label: String {
        self.rawValue
    }
    
    public var iconName: String {
        switch self {
        case .photoUpload:
            return "camera"
        case .menuNotExists:
            return "mappin.slash"
        case .pfcError:
            return "exclamationmark.bubble"
        }
    }
}
