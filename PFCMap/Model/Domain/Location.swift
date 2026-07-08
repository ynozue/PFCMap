import Foundation

struct Location: Sendable, Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    nonisolated init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// 位置情報が取得できない場合のフォールバック地点（東京駅）
    static let tokyoStation = Location(latitude: 35.681236, longitude: 139.767125)
}

import CoreLocation

extension Location {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    func distance(to other: Location) -> Double {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return from.distance(from: to)
    }
}
