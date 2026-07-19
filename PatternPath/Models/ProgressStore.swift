import Foundation
import SwiftUI

@Observable
final class ProgressStore {
    private let defaults: UserDefaults

    private(set) var starsByLevel: [Int: Int]
    private(set) var highestUnlocked: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: UserDefaultsKeys.stars),
           let decoded = try? JSONDecoder().decode([Int: Int].self, from: data) {
            starsByLevel = decoded
        } else {
            starsByLevel = [:]
        }
        let unlocked = defaults.integer(forKey: UserDefaultsKeys.unlocked)
        highestUnlocked = max(1, unlocked == 0 ? 1 : unlocked)
    }

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    var clearedLevelCount: Int {
        starsByLevel.values.filter { $0 > 0 }.count
    }

    func stars(for levelID: Int) -> Int {
        starsByLevel[levelID] ?? 0
    }

    func isCleared(_ levelID: Int) -> Bool {
        stars(for: levelID) > 0
    }

    func isUnlocked(_ levelID: Int) -> Bool {
        levelID <= highestUnlocked
    }

    func clearedCount(inWorld worldID: Int) -> Int {
        worldRange(worldID).filter { isCleared($0) }.count
    }

    func worldFill(worldID: Int) -> Double {
        Double(clearedCount(inWorld: worldID)) / 10.0
    }

    func isStickerUnlocked(milestone: Int) -> Bool {
        isCleared(milestone)
    }

    var unlockedStickers: [GarageSticker] {
        StickerCatalog.all.filter { isStickerUnlocked(milestone: $0.milestone) }
    }

    /// World id if this clear finished a world (10, 20, 30, 40, 50).
    func worldCompleted(byClearing levelID: Int) -> Int? {
        guard levelID % 10 == 0 else { return nil }
        return GameLevel.worldID(for: levelID)
    }

    @discardableResult
    func recordClear(levelID: Int, stars: Int, mistakes: Int) -> ClearReward {
        let wasCleared = isCleared(levelID)
        let earned = GameSession.stars(forMistakes: mistakes, maxStars: stars)
        let previous = starsByLevel[levelID] ?? 0
        starsByLevel[levelID] = max(previous, earned)

        if levelID >= highestUnlocked, levelID < LevelCatalog.totalCount {
            highestUnlocked = levelID + 1
        }

        persist()

        let sticker: GarageSticker? = wasCleared ? nil : StickerCatalog.stickerUnlocked(byClearing: levelID)
        let world: Int? = wasCleared ? nil : worldCompleted(byClearing: levelID)
        return ClearReward(
            starsEarned: starsByLevel[levelID] ?? earned,
            isNewBest: earned > previous,
            newSticker: sticker,
            completedWorldID: world
        )
    }

    func resetAll() {
        starsByLevel = [:]
        highestUnlocked = 1
        persist()
    }

    private func worldRange(_ worldID: Int) -> ClosedRange<Int> {
        switch worldID {
        case 1: 1...10
        case 2: 11...20
        case 3: 21...30
        case 4: 31...40
        default: 41...50
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(starsByLevel) {
            defaults.set(data, forKey: UserDefaultsKeys.stars)
        }
        defaults.set(highestUnlocked, forKey: UserDefaultsKeys.unlocked)
    }
}

struct ClearReward: Equatable {
    let starsEarned: Int
    let isNewBest: Bool
    let newSticker: GarageSticker?
    let completedWorldID: Int?
}
