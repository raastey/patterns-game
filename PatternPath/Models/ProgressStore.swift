import Foundation
import SwiftUI

@Observable
final class ProgressStore {
    private let defaults = UserDefaults.standard
    private let starsKey = "patternpath.stars"
    private let unlockedKey = "patternpath.unlocked"

    private(set) var starsByLevel: [Int: Int]
    private(set) var highestUnlocked: Int

    init() {
        if let data = defaults.data(forKey: starsKey),
           let decoded = try? JSONDecoder().decode([Int: Int].self, from: data) {
            starsByLevel = decoded
        } else {
            starsByLevel = [:]
        }
        let unlocked = defaults.integer(forKey: unlockedKey)
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
        let range: ClosedRange<Int>
        switch worldID {
        case 1: range = 1...10
        case 2: range = 11...20
        case 3: range = 21...30
        case 4: range = 31...40
        default: range = 41...50
        }
        return range.filter { isCleared($0) }.count
    }

    /// How full a world garage bay is (0...1).
    func worldFill(worldID: Int) -> Double {
        Double(clearedCount(inWorld: worldID)) / 10.0
    }

    func isStickerUnlocked(milestone: Int) -> Bool {
        isCleared(milestone)
    }

    var unlockedStickers: [GarageSticker] {
        StickerCatalog.all.filter { isStickerUnlocked(milestone: $0.milestone) }
    }

    /// Returns a newly unlocked sticker when clearing a milestone level for the first time.
    @discardableResult
    func recordClear(levelID: Int, stars: Int, mistakes: Int) -> GarageSticker? {
        let wasCleared = isCleared(levelID)
        let earned = max(1, min(3, stars - min(mistakes, 2)))
        let previous = starsByLevel[levelID] ?? 0
        starsByLevel[levelID] = max(previous, earned)

        if levelID >= highestUnlocked, levelID < LevelCatalog.totalCount {
            highestUnlocked = levelID + 1
        }

        persist()

        guard !wasCleared else { return nil }
        return StickerCatalog.stickerUnlocked(byClearing: levelID)
    }

    func resetAll() {
        starsByLevel = [:]
        highestUnlocked = 1
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(starsByLevel) {
            defaults.set(data, forKey: starsKey)
        }
        defaults.set(highestUnlocked, forKey: unlockedKey)
    }
}
