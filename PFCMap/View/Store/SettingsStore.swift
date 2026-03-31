import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class SettingsStore {
    private let userDefaultsService: any UserDefaultsService

    var mapDistance: Int = 500
    var proteinThreshold: Int = 20
    var fatThreshold: Int = 20
    var disabledShopIds: Set<UUID> = []

    init(userDefaultsService: any UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
        
        Task {
            await loadSettings()
        }
    }

    func loadSettings() async {
        self.mapDistance = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.mapDistance)
        self.proteinThreshold = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.proteinThreshold)
        self.fatThreshold = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.fatThreshold)
        let ids: [UUID] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        self.disabledShopIds = Set(ids)
    }

    func updateMapDistance(_ distance: Int) {
        self.mapDistance = distance
        Task {
            await userDefaultsService.save(key:  PFCMapUserDefaultsKeys.mapDistance, value: distance)
        }
    }

    func updateProteinThreshold(_ threshold: Int) {
        self.proteinThreshold = threshold
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: threshold)
        }
    }

    func updateFatThreshold(_ threshold: Int) {
        self.fatThreshold = threshold
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: threshold)
        }
    }

    func updateDisabledShopIds(_ ids: Set<UUID>) {
        self.disabledShopIds = ids
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: Array(ids))
        }
    }
}
