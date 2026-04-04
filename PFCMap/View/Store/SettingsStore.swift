import SwiftUI
import Observation
import NZData

@MainActor
@Observable
final class SettingsStore {
    var mapDistance: MapDistance = .m500
    var proteinThreshold: ProteinThreshold = .g20
    var fatThreshold: FatThreshold = .g20
    var disabledShopIds: Set<UUID> = []
    var lastFetchedAt: Date? = nil

    init() {}

    func updateSettings(
        mapDistance: MapDistance,
        proteinThreshold: ProteinThreshold,
        fatThreshold: FatThreshold,
        disabledShopIds: Set<UUID>,
        lastFetchedAt: Date?
    ) {
        self.mapDistance = mapDistance
        self.proteinThreshold = proteinThreshold
        self.fatThreshold = fatThreshold
        self.disabledShopIds = disabledShopIds
        self.lastFetchedAt = lastFetchedAt
    }

    func updateMapDistance(_ distance: MapDistance) {
        self.mapDistance = distance
    }

    func updateProteinThreshold(_ threshold: ProteinThreshold) {
        self.proteinThreshold = threshold
    }

    func updateFatThreshold(_ threshold: FatThreshold) {
        self.fatThreshold = threshold
    }

    func updateDisabledShopIds(_ ids: Set<UUID>) {
        self.disabledShopIds = ids
    }

    func updateLastFetchedAt(_ date: Date?) {
        self.lastFetchedAt = date
    }
}
