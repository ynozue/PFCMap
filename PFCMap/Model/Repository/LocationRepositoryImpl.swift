import Foundation
import CoreLocation

/// LocationRepositoryの実装
/// CLLocationManagerは@MainActorを必要とするため、actorではなくfinal classとして定義し、
/// 実際の位置情報取得処理は@MainActorなLocationManagerHelperに委譲する
final class LocationRepositoryImpl: Sendable {
    // LocationManagerHelperは@MainActorに隔離されているため、直接保持せずに
    // メソッド呼び出し時にMainActor上で生成・使用する
    init() {}
}

extension LocationRepositoryImpl: LocationRepository {
    func requestLocation() async throws -> Location {
        try await LocationManagerHelper.shared.requestLocation()
    }
}

@MainActor
private final class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManagerHelper()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<Location, any Error>?
    private var authContinuation: CheckedContinuation<Void, Never>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() async throws -> Location {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            await withCheckedContinuation { continuation in
                self.authContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            authContinuation?.resume()
            authContinuation = nil
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
