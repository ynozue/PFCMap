import SwiftUI
import MapKit
import Observation

@MainActor
@Observable
final class FirstPageModel {
    var cameraPosition: MapCameraPosition = .automatic
    
    // 他のUI状態を管理
    var isLoading = false
    
    init() {}
    
    // Map関連のアクションがあればここに追加
}
