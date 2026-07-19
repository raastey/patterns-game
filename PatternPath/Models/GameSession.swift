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

    /// Slot indices filled by the player this run, oldest first.
    private var placementStack: [Int] = []

    init(level: GameLevel, shuffleChoices: Bool = true) {
        self.level = level
        self.slots = level.slots
        self.choices = shuffleChoices ? level.choices.shuffled() : level.choices
    }

    var progressText: String {
        "\(nextAnswerIndex)/\(level.answers.count)"
    }

    var isComplete: Bool {
        nextAnswerIndex >= level.answers.count
    }

    var canUndo: Bool {
        phase == .playing && !placementStack.isEmpty
    }

    var activeBlankIndex: Int? {
        slots.firstIndex(where: \.isBlank)
    }

    /// Choice that matches the next answer (for first-run coach).
    var coachChoiceID: UUID? {
        guard phase == .playing, !isComplete else { return nil }
        let expected = level.answers[nextAnswerIndex]
        return choices.first(where: { $0.matches(expected) })?.id
    }

    func place(_ choice: PatternToken) {
        guard phase == .playing, !isComplete else { return }
        guard let blankIndex = slots.firstIndex(where: \.isBlank) else { return }

        HapticsPlayer.shared.warmUp()

        let expected = level.answers[nextAnswerIndex]
        if choice.matches(expected) {
            applyCorrect(expected: expected, blankIndex: blankIndex)
        } else {
            applyWrong(choiceID: choice.id, blankIndex: blankIndex)
        }
    }

    func undoLastPlacement() {
        guard canUndo, let slotIndex = placementStack.popLast() else { return }
        guard nextAnswerIndex > 0 else { return }

        SoundPlayer.shared.playUndo()
        HapticsPlayer.shared.tap()

        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
            slots[slotIndex] = .blank(UUID())
            nextAnswerIndex -= 1
            lastPlacedIndex = placementStack.last
            wrongChoiceID = nil
            shakeBlankIndex = nil
            streak = 0
        }
    }

    func starsEarned() -> Int {
        Self.stars(forMistakes: mistakes, maxStars: level.starsToEarn)
    }

    static func stars(forMistakes mistakes: Int, maxStars: Int = 3) -> Int {
        max(1, min(3, maxStars - min(mistakes, 2)))
    }

    private func applyCorrect(expected: PatternToken, blankIndex: Int) {
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
            placementStack.append(blankIndex)
            wrongChoiceID = nil
            popToken += 1
        }

        if isComplete {
            let earned = starsEarned()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                guard let self else { return }
                SoundPlayer.shared.playCelebrate()
                HapticsPlayer.shared.celebrate(stars: earned)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    self.phase = .celebrating
                }
            }
        }
    }

    private func applyWrong(choiceID: UUID, blankIndex: Int) {
        mistakes += 1
        streak = 0
        SoundPlayer.shared.playWrong()
        HapticsPlayer.shared.wrong()
        wrongChoiceID = choiceID
        shakeBlankIndex = blankIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            withAnimation {
                self?.shakeBlankIndex = nil
                self?.wrongChoiceID = nil
            }
        }
    }
}
