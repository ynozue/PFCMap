import Foundation
import NZData

actor UserDefaultsServiceDummy: UserDefaultsService {
    init() {}

    func save<T>(key: UserDefaultsKey<T>, value: T) async where T : Sendable {}
    func value<T>(key: UserDefaultsKey<T>) async -> T where T : Sendable { return key.defaultValue }
    func remove<T>(key: UserDefaultsKey<T>) async where T : Sendable {}
    func removeAll() async {}
}
