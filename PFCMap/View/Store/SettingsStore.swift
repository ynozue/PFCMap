import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class SettingsStore {
    private let userDefaultsService: any UserDefaultsService

    var mapDistance: MapDistance = .m500
    var proteinThreshold: ProteinThreshold = .g20
    var fatThreshold: FatThreshold = .g20
    var disabledShopIds: Set<UUID> = []

    init(userDefaultsService: any UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
        
        Task {
            await loadSettings()
        }
    }

    func loadSettings() async {
        let distance: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.mapDistance)
        self.mapDistance = MapDistance(rawValue: distance) ?? .m500
        
        let protein: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.proteinThreshold)
        self.proteinThreshold = ProteinThreshold(rawValue: protein) ?? .g20
        
        let fat: Int = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.fatThreshold)
        self.fatThreshold = FatThreshold(rawValue: fat) ?? .g20

        let ids: [UUID] = await userDefaultsService.value(key: PFCMapUserDefaultsKeys.disabledShopIds)
        self.disabledShopIds = Set(ids)
    }

    func updateMapDistance(_ distance: MapDistance) {
        self.mapDistance = distance
        Task {
            await userDefaultsService.save(key:  PFCMapUserDefaultsKeys.mapDistance, value: distance.rawValue)
        }
    }

    func updateProteinThreshold(_ threshold: ProteinThreshold) {
        self.proteinThreshold = threshold
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.proteinThreshold, value: threshold.rawValue)
        }
    }

    func updateFatThreshold(_ threshold: FatThreshold) {
        self.fatThreshold = threshold
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.fatThreshold, value: threshold.rawValue)
        }
    }

    func updateDisabledShopIds(_ ids: Set<UUID>) {
        self.disabledShopIds = ids
        Task {
            await userDefaultsService.save(key: PFCMapUserDefaultsKeys.disabledShopIds, value: Array(ids))
        }
    }
}
