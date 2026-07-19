import Foundation

enum GameSessionTests {
    static func run() -> Bool {
        var ok = true

        if GameSession.stars(forMistakes: 0) != 3 {
            print("FAIL stars 0 mistakes should be 3")
            ok = false
        }
        if GameSession.stars(forMistakes: 1) != 2 {
            print("FAIL stars 1 mistake should be 2")
            ok = false
        }
        if GameSession.stars(forMistakes: 2) != 1 {
            print("FAIL stars 2 mistakes should be 1")
            ok = false
        }
        if GameSession.stars(forMistakes: 5) != 1 {
            print("FAIL stars many mistakes should clamp to 1")
            ok = false
        }

        guard let level = LevelCatalog.level(id: 1) else {
            print("FAIL missing level 1")
            return false
        }

        let session = GameSession(level: level, shuffleChoices: false)
        guard let expected = level.answers.first else {
            print("FAIL level 1 has no answers")
            return false
        }
        guard let choice = session.choices.first(where: { $0.matches(expected) }) else {
            print("FAIL level 1 missing matching choice")
            return false
        }

        let blanksBefore = session.slots.filter(\.isBlank).count
        session.place(choice)
        if session.nextAnswerIndex != 1 {
            print("FAIL place did not advance answer index")
            ok = false
        }
        if session.slots.filter(\.isBlank).count != blanksBefore - 1 {
            print("FAIL place did not fill a blank")
            ok = false
        }
        if !session.canUndo {
            print("FAIL canUndo should be true after place")
            ok = false
        }

        session.undoLastPlacement()
        if session.nextAnswerIndex != 0 {
            print("FAIL undo did not restore answer index")
            ok = false
        }
        if session.slots.filter(\.isBlank).count != blanksBefore {
            print("FAIL undo did not restore blank")
            ok = false
        }
        if session.canUndo {
            print("FAIL canUndo should be false after full undo")
            ok = false
        }

        if session.coachChoiceID == nil {
            print("FAIL coachChoiceID missing at start of level")
            ok = false
        }

        if ok {
            print("GameSessionTests passed")
        }
        return ok
    }
}
