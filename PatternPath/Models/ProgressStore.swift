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

    func stars(for levelID: Int) -> Int {
        starsByLevel[levelID] ?? 0
    }

    func isUnlocked(_ levelID: Int) -> Bool {
        levelID <= highestUnlocked
    }

    func recordClear(levelID: Int, stars: Int, mistakes: Int) {
        let earned = max(1, min(3, stars - min(mistakes, 2)))
        let previous = starsByLevel[levelID] ?? 0
        starsByLevel[levelID] = max(previous, earned)

        if levelID >= highestUnlocked, levelID < LevelCatalog.totalCount {
            highestUnlocked = levelID + 1
        }

        persist()
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
