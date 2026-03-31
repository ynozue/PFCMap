import Foundation
import NZData

public actor UserDefaultsServiceDummy: UserDefaultsService {
    public init() {}

    public func save<T>(key: UserDefaultsKey<T>, value: T) async where T : Sendable {}
    public func value<T>(key: UserDefaultsKey<T>) async -> T where T : Sendable { return key.defaultValue }
    public func remove<T>(key: UserDefaultsKey<T>) async where T : Sendable {}
    public func removeAll() async {}
}
