import Foundation
import CoreLocation

/// LocationRepositoryの実装
/// CLLocationManagerは@MainActorを必要とするため、actorではなくfinal classとして定義し、
/// 実際の位置情報取得処理は@MainActorなLocationManagerHelperに委譲する
public final class LocationRepositoryImpl: Sendable {
    // LocationManagerHelperは@MainActorに隔離されているため、直接保持せずに
    // メソッド呼び出し時にMainActor上で生成・使用する
    public init() {}
}

extension LocationRepositoryImpl: LocationRepository {
    public func requestLocation() async throws -> Location {
        try await LocationManagerHelper.shared.requestLocation()
    }
}

@MainActor
private final class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManagerHelper()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<Location, any Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() async throws -> Location {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let domainLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        continuation?.resume(returning: domainLocation)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
