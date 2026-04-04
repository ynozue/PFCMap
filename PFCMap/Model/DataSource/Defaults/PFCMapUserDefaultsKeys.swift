import Foundation
import NZData

enum PFCMapUserDefaultsKeys {
    static let mapDistance = UserDefaultsKey(name: "mapDistance", defaultValue: 500)
    static let proteinThreshold = UserDefaultsKey(name: "proteinThreshold", defaultValue: 20)
    static let fatThreshold = UserDefaultsKey(name: "fatThreshold", defaultValue: 20)
    static let lastFetchedAt = UserDefaultsKey<Date?>(name: "lastFetchedAt", defaultValue: nil)
    static let disabledShopIds = UserDefaultsKey(name: "disabledShopIds", defaultValue: [UUID]())
}
