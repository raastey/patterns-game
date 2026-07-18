import CoreHaptics
import Foundation
import UIKit

/// Rich haptic choreography for joyful kid feedback.
/// Uses Core Haptics when available, with UIKit fallbacks.
@Observable
final class HapticsPlayer {
    static let shared = HapticsPlayer()

    private let enabledKey = "patternpath.hapticsEnabled"
    private var engine: CHHapticEngine?
    private var supportsHaptics = false
    private var engineRunning = false

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: enabledKey)
            if isEnabled {
                prepare()
                tap()
            }
        }
    }

    private init() {
        if UserDefaults.standard.object(forKey: enabledKey) == nil {
            isEnabled = true
        } else {
            isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        }
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepare()
        startEngineIfNeeded()
    }

    func toggle() {
        isEnabled.toggle()
    }

    func prepare() {
        light.prepare()
        soft.prepare()
        medium.prepare()
        heavy.prepare()
        rigid.prepare()
        selection.prepare()
        notification.prepare()
    }

    // MARK: - Public cues

    func tap() {
        guard isEnabled else { return }
        run(Self.tapPattern) {
            soft.impactOccurred(intensity: 0.7)
        }
    }

    func select() {
        guard isEnabled else { return }
        run(Self.selectPattern) {
            selection.selectionChanged()
        }
    }

    func navigate() {
        guard isEnabled else { return }
        run(Self.navigatePattern) {
            medium.impactOccurred(intensity: 0.8)
        }
    }

    func levelStart() {
        guard isEnabled else { return }
        run(Self.levelStartPattern) {
            soft.impactOccurred(intensity: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                self?.medium.impactOccurred(intensity: 0.7)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { [weak self] in
                self?.light.impactOccurred(intensity: 0.85)
            }
        }
    }

    /// Rising joy as kids fill more blanks in a level.
    func correct(step: Int, total: Int) {
        guard isEnabled else { return }
        let progress = total > 0 ? Float(step) / Float(total) : 0.5
        run(Self.correctPattern(progress: progress)) {
            let intensity = CGFloat(0.55 + 0.4 * Double(progress))
            rigid.impactOccurred(intensity: intensity)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.soft.impactOccurred(intensity: min(1, intensity + 0.15))
            }
            if progress > 0.65 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                    self?.light.impactOccurred(intensity: 0.95)
                }
            }
            if progress > 0.9 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.heavy.impactOccurred(intensity: 0.85)
                }
            }
        }
    }

    func wrong() {
        guard isEnabled else { return }
        // Soft and friendly — never a harsh buzz.
        run(Self.wrongPattern) {
            soft.impactOccurred(intensity: 0.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.soft.impactOccurred(intensity: 0.28)
            }
        }
    }

    func celebrate(stars: Int) {
        guard isEnabled else { return }
        run(Self.celebratePattern(stars: stars)) {
            notification.notificationOccurred(.success)
            let beats: [(TimeInterval, () -> Void)] = [
                (0.1, { [weak self] in self?.heavy.impactOccurred(intensity: 1.0) }),
                (0.24, { [weak self] in self?.medium.impactOccurred(intensity: 0.9) }),
                (0.38, { [weak self] in self?.rigid.impactOccurred(intensity: 1.0) }),
                (0.52, { [weak self] in self?.light.impactOccurred(intensity: 1.0) }),
                (0.66, { [weak self] in self?.soft.impactOccurred(intensity: 0.85) }),
                (0.8, { [weak self] in self?.heavy.impactOccurred(intensity: 0.75) }),
                (0.95, { [weak self] in self?.rigid.impactOccurred(intensity: 0.9) })
            ]
            for (delay, beat) in beats {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: beat)
            }
            if stars >= 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) { [weak self] in
                    self?.notification.notificationOccurred(.success)
                    self?.heavy.impactOccurred(intensity: 1.0)
                }
            }
        }
    }

    func starPop(index: Int) {
        guard isEnabled else { return }
        run(Self.starPopPattern(index: index)) {
            let intensity = CGFloat(0.7 + Double(index) * 0.12)
            rigid.impactOccurred(intensity: min(1, intensity))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) { [weak self] in
                self?.light.impactOccurred(intensity: 1.0)
            }
        }
    }

    func unlock() {
        guard isEnabled else { return }
        run(Self.unlockPattern) {
            notification.notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.heavy.impactOccurred(intensity: 0.95)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.light.impactOccurred(intensity: 0.9)
            }
        }
    }

    func pressDown() {
        guard isEnabled else { return }
        soft.impactOccurred(intensity: 0.5)
    }

    func welcome() {
        guard isEnabled else { return }
        run(Self.welcomePattern) {
            soft.impactOccurred(intensity: 0.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.light.impactOccurred(intensity: 0.7)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.soft.impactOccurred(intensity: 0.55)
            }
        }
    }

    // MARK: - Engine

    private func startEngineIfNeeded() {
        guard supportsHaptics else { return }
        if engine == nil {
            do {
                let newEngine = try CHHapticEngine()
                newEngine.isAutoShutdownEnabled = true
                newEngine.resetHandler = { [weak self] in
                    self?.engineRunning = false
                    try? self?.engine?.start()
                    self?.engineRunning = true
                }
                newEngine.stoppedHandler = { [weak self] _ in
                    self?.engineRunning = false
                }
                engine = newEngine
            } catch {
                supportsHaptics = false
                return
            }
        }
        guard let engine, !engineRunning else { return }
        do {
            try engine.start()
            engineRunning = true
        } catch {
            engineRunning = false
        }
    }

    private func run(_ events: [CHHapticEvent], fallback: () -> Void) {
        guard supportsHaptics else {
            fallback()
            return
        }
        startEngineIfNeeded()
        guard let engine else {
            fallback()
            return
        }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            fallback()
        }
    }

    // MARK: - Patterns

    private static var tapPattern: [CHHapticEvent] {
        [.transient(time: 0, intensity: 0.55, sharpness: 0.35)]
    }

    private static var selectPattern: [CHHapticEvent] {
        [
            .transient(time: 0, intensity: 0.5, sharpness: 0.25),
            .transient(time: 0.04, intensity: 0.35, sharpness: 0.2)
        ]
    }

    private static var navigatePattern: [CHHapticEvent] {
        [
            .transient(time: 0, intensity: 0.7, sharpness: 0.5),
            .continuous(time: 0.02, duration: 0.07, intensity: 0.4, sharpness: 0.25)
        ]
    }

    private static var levelStartPattern: [CHHapticEvent] {
        [
            .continuous(time: 0, duration: 0.14, intensity: 0.4, sharpness: 0.2),
            .transient(time: 0.08, intensity: 0.75, sharpness: 0.45),
            .transient(time: 0.16, intensity: 0.5, sharpness: 0.65)
        ]
    }

    private static func correctPattern(progress: Float) -> [CHHapticEvent] {
        let pop = 0.65 + 0.35 * progress
        let sparkle = 0.45 + 0.5 * progress
        var events: [CHHapticEvent] = [
            .transient(time: 0, intensity: pop, sharpness: 0.55),
            .continuous(time: 0.02, duration: 0.09, intensity: 0.4 + 0.35 * progress, sharpness: 0.3),
            .transient(time: 0.07, intensity: sparkle, sharpness: 0.8)
        ]
        if progress > 0.5 {
            events.append(.transient(time: 0.13, intensity: 0.6 + 0.35 * progress, sharpness: 0.95))
        }
        if progress > 0.85 {
            events.append(.transient(time: 0.2, intensity: 1.0, sharpness: 1.0))
            events.append(.continuous(time: 0.2, duration: 0.12, intensity: 0.4, sharpness: 0.65))
        }
        return events
    }

    private static var wrongPattern: [CHHapticEvent] {
        [
            .transient(time: 0, intensity: 0.38, sharpness: 0.08),
            .transient(time: 0.09, intensity: 0.26, sharpness: 0.04)
        ]
    }

    private static func celebratePattern(stars: Int) -> [CHHapticEvent] {
        var events: [CHHapticEvent] = [
            .transient(time: 0, intensity: 1.0, sharpness: 0.75),
            .continuous(time: 0.02, duration: 0.2, intensity: 0.6, sharpness: 0.4),
            .transient(time: 0.12, intensity: 0.9, sharpness: 0.95),
            .transient(time: 0.22, intensity: 0.8, sharpness: 0.65),
            .transient(time: 0.34, intensity: 1.0, sharpness: 1.0),
            .continuous(time: 0.34, duration: 0.22, intensity: 0.45, sharpness: 0.55),
            .transient(time: 0.48, intensity: 0.75, sharpness: 0.85),
            .transient(time: 0.6, intensity: 0.95, sharpness: 1.0),
            .transient(time: 0.74, intensity: 0.7, sharpness: 0.75),
            .transient(time: 0.88, intensity: 0.85, sharpness: 1.0)
        ]
        if stars >= 2 {
            events.append(.transient(time: 1.0, intensity: 0.9, sharpness: 1.0))
        }
        if stars >= 3 {
            events.append(.continuous(time: 1.05, duration: 0.25, intensity: 0.5, sharpness: 0.6))
            events.append(.transient(time: 1.15, intensity: 1.0, sharpness: 1.0))
            events.append(.transient(time: 1.28, intensity: 0.75, sharpness: 0.9))
            events.append(.transient(time: 1.4, intensity: 0.95, sharpness: 1.0))
        }
        return events
    }

    private static func starPopPattern(index: Int) -> [CHHapticEvent] {
        let boost = Float(index) * 0.12
        return [
            .transient(time: 0, intensity: min(1, 0.78 + boost), sharpness: 0.9),
            .transient(time: 0.05, intensity: min(1, 0.6 + boost), sharpness: 1.0),
            .continuous(time: 0.02, duration: 0.09, intensity: 0.35, sharpness: 0.65)
        ]
    }

    private static var unlockPattern: [CHHapticEvent] {
        [
            .continuous(time: 0, duration: 0.12, intensity: 0.45, sharpness: 0.35),
            .transient(time: 0.08, intensity: 0.95, sharpness: 0.75),
            .transient(time: 0.16, intensity: 0.75, sharpness: 1.0)
        ]
    }

    private static var welcomePattern: [CHHapticEvent] {
        [
            .transient(time: 0, intensity: 0.45, sharpness: 0.3),
            .transient(time: 0.1, intensity: 0.6, sharpness: 0.5),
            .transient(time: 0.2, intensity: 0.5, sharpness: 0.65)
        ]
    }
}

private extension CHHapticEvent {
    static func transient(time: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time
        )
    }

    static func continuous(time: TimeInterval, duration: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time,
            duration: duration
        )
    }
}
