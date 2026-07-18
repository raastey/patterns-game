import Foundation
import SwiftUI

enum PlayPhase: Equatable {
    case playing
    case celebrating
}

@Observable
final class GameSession {
    let level: GameLevel
    private(set) var slots: [PatternSlot]
    private(set) var choices: [PatternToken]
    private(set) var nextAnswerIndex: Int = 0
    private(set) var mistakes: Int = 0
    private(set) var streak: Int = 0
    private(set) var phase: PlayPhase = .playing
    private(set) var shakeBlankIndex: Int?
    private(set) var lastPlacedIndex: Int?
    private(set) var wrongChoiceID: UUID?
    private(set) var popToken: Int = 0

    init(level: GameLevel) {
        self.level = level
        self.slots = level.slots
        self.choices = level.choices.shuffled()
    }

    var progressText: String {
        "\(nextAnswerIndex)/\(level.answers.count)"
    }

    var isComplete: Bool {
        nextAnswerIndex >= level.answers.count
    }

    func place(_ choice: PatternToken) {
        guard phase == .playing, !isComplete else { return }
        guard let blankIndex = slots.firstIndex(where: \.isBlank) else { return }

        // Always warm the engine on the kid's real touch.
        HapticsPlayer.shared.warmUp()

        let expected = level.answers[nextAnswerIndex]
        if choice.matches(expected) {
            SoundPlayer.shared.playCorrect()
            let nextStep = nextAnswerIndex + 1
            streak += 1
            HapticsPlayer.shared.correct(step: nextStep, total: level.answers.count)
            if streak >= 2 {
                HapticsPlayer.shared.combo(count: streak)
                SoundPlayer.shared.playStreak()
            }

            withAnimation(.spring(response: 0.42, dampingFraction: 0.62)) {
                slots[blankIndex] = .filled(expected.fresh())
                nextAnswerIndex += 1
                lastPlacedIndex = blankIndex
                wrongChoiceID = nil
                popToken += 1
            }

            if isComplete {
                let earned = starsEarned()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                    SoundPlayer.shared.playCelebrate()
                    HapticsPlayer.shared.celebrate(stars: earned)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        self.phase = .celebrating
                    }
                }
            }
        } else {
            mistakes += 1
            streak = 0
            SoundPlayer.shared.playWrong()
            HapticsPlayer.shared.wrong()
            wrongChoiceID = choice.id
            shakeBlankIndex = blankIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation {
                    self.shakeBlankIndex = nil
                    self.wrongChoiceID = nil
                }
            }
        }
    }

    func starsEarned() -> Int {
        max(1, min(3, level.starsToEarn - min(mistakes, 2)))
    }
}
