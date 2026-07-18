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
        }

        if ok {
            print("LevelLogicTests passed: \(LevelCatalog.totalCount) unique toy garage levels")
        }
        return ok
    }
}
