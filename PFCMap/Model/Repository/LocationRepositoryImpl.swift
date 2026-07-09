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
    
    func prefetchLocation() {
        Task { @MainActor in
            LocationManagerHelper.shared.prefetchLocation()
        }
    }
    
    func requestAuthorization() async -> Bool {
        await LocationManagerHelper.shared.requestAuthorization()
    }
}

@MainActor
private final class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManagerHelper()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<Location, any Error>?
    private var authContinuation: CheckedContinuation<Void, Never>?
    
    // 最新の取得位置情報と取得時間をキャッシュ
    private var cachedLocation: Location?
    private var lastFetchTime: Date?
    
    // 進行中のプリフェッチタスクがあるか確認するためのフラグ
    private var isPrefetching = false
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func prefetchLocation() {
        let status = locationManager.authorizationStatus
        // 既に許可されている場合のみ実行
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return
        }
        
        // すでにプリフェッチ実行中、または有効なキャッシュ（60秒以内）がある場合はスキップ
        if isPrefetching { return }
        if let lastFetchTime = lastFetchTime, Date().timeIntervalSince(lastFetchTime) < 60 {
            return
        }
        
        isPrefetching = true
        locationManager.requestLocation()
    }
    
    func requestAuthorization() async -> Bool {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            await withCheckedContinuation { continuation in
                self.authContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        let newStatus = locationManager.authorizationStatus
        return newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways
    }
    
    func requestLocation() async throws -> Location {
        // 有効なキャッシュ（60秒以内）があれば即座にそれを返す
        if let cached = cachedLocation, let lastFetchTime = lastFetchTime, Date().timeIntervalSince(lastFetchTime) < 60 {
            print("⏱️ [Location] Return cached location")
            return cached
        }
        
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            await withCheckedContinuation { continuation in
                self.authContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            if !isPrefetching {
                locationManager.requestLocation()
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            authContinuation?.resume()
            authContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isPrefetching = false
        guard let location = locations.last else { return }
        let domainLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.cachedLocation = domainLocation
        self.lastFetchTime = Date()
        
        continuation?.resume(returning: domainLocation)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        isPrefetching = false
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
