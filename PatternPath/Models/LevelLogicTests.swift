import Foundation

enum LevelLogicTests {
    static func run() -> Bool {
        var ok = true

        if LevelCatalog.all.count != LevelCatalog.totalCount {
            print("FAIL expected \(LevelCatalog.totalCount) levels, got \(LevelCatalog.all.count)")
            ok = false
        }

        let ids = LevelCatalog.all.map(\.id)
        if Set(ids).count != ids.count {
            print("FAIL duplicate level ids")
            ok = false
        }

        var seenSignatures = Set<String>()

        for level in LevelCatalog.all {
            let blanks = level.slots.filter(\.isBlank).count
            if blanks != level.answers.count {
                print("FAIL level \(level.id): blank count \(blanks) != answers \(level.answers.count)")
                ok = false
            }

            if level.choices.isEmpty {
                print("FAIL level \(level.id): no choices")
                ok = false
            }

            for answer in level.answers {
                let hasMatch = level.choices.contains { $0.matches(answer) }
                if !hasMatch {
                    print("FAIL level \(level.id): answer \(answer.accessibilityLabel) missing from choices")
                    ok = false
                }
            }

            let filled = level.slots.compactMap(\.token) + level.answers
            let toys = Set(filled.map(\.toy))
            let hues = Set(filled.map(\.hue))

            switch level.focus {
            case .color:
                if toys.count != 1 {
                    print("FAIL level \(level.id): color focus but multiple toys \(toys)")
                    ok = false
                }
                let choiceToys = Set(level.choices.map(\.toy))
                if choiceToys != toys {
                    print("FAIL level \(level.id): color choices must share the path toy")
                    ok = false
                }
            case .toy:
                if hues.count != 1 {
                    print("FAIL level \(level.id): toy focus but multiple hues \(hues)")
                    ok = false
                }
                let choiceHues = Set(level.choices.map(\.hue))
                if choiceHues != hues {
                    print("FAIL level \(level.id): toy choices must share the path color")
                    ok = false
                }
            }

            let signature = level.slots.map { slot -> String in
                switch slot {
                case .filled(let token): return "\(token.toy.rawValue)-\(token.hue.rawValue)"
                case .blank: return "_"
                }
            }.joined(separator: "|") + "#\(level.focus.rawValue)"

            if !seenSignatures.insert(signature).inserted {
                print("FAIL duplicate pattern at level \(level.id): \(signature)")
                ok = false
            }

            if level.columns < 1 {
                print("FAIL level \(level.id): columns < 1")
                ok = false
            }
            if level.slots.count >= 4, level.rowCount < 2 {
                print("FAIL level \(level.id): expected multi-row board, got \(level.rowCount) row(s)")
                ok = false
            }

            if !patternIsReadable(level) {
                ok = false
            }
        }

        if ok {
            print("LevelLogicTests passed: \(LevelCatalog.totalCount) unique toy garage levels")
        }
        return ok
    }

    /// Every level must show one full pattern unit before any blank (or the outbound half of a mirror).
    private static func patternIsReadable(_ level: GameLevel) -> Bool {
        var intended: [PatternToken] = []
        var answerIndex = 0
        var blankMask: [Bool] = []
        for slot in level.slots {
            switch slot {
            case .filled(let token):
                intended.append(token)
                blankMask.append(false)
            case .blank:
                guard answerIndex < level.answers.count else {
                    print("FAIL level \(level.id): blank without answer")
                    return false
                }
                intended.append(level.answers[answerIndex])
                answerIndex += 1
                blankMask.append(true)
            }
        }

        let keys: [String] = intended.map { token in
            switch level.focus {
            case .color: token.hue.rawValue
            case .toy: token.toy.rawValue
            }
        }

        if let period = shortestPeriod(keys) {
            if blankMask.prefix(period).contains(true) {
                print("FAIL level \(level.id): blank inside first cycle (period \(period))")
                return false
            }
            return true
        }

        if keys == Array(keys.reversed()), keys.count >= 4 {
            let half = keys.count / 2
            if blankMask.prefix(half).contains(true) {
                print("FAIL level \(level.id): blank inside mirror outbound half")
                return false
            }
            return true
        }

        print("FAIL level \(level.id): sequence has no clear repeating unit")
        return false
    }

    private static func shortestPeriod(_ keys: [String]) -> Int? {
        let n = keys.count
        guard n >= 2 else { return nil }
        for period in 1...(n / 2) {
            if (0..<n).allSatisfy({ keys[$0] == keys[$0 % period] }) {
                return period
            }
        }
        return nil
    }
}
