import AudioToolbox
import CoreHaptics
import Foundation
import UIKit

/// Maximum-intensity haptics. Always fires UIKit + system taps;
/// layers Core Haptics on top when the hardware supports it.
@Observable
final class HapticsPlayer {
    static let shared = HapticsPlayer()

    private var engine: CHHapticEngine?
    private var supportsCoreHaptics = false

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    /// System "Pop" / "Peek" / "Nope" — often felt even when other APIs feel weak.
    private let systemPeek: SystemSoundID = 1519
    private let systemPop: SystemSoundID = 1520
    private let systemNope: SystemSoundID = 1521

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: UserDefaultsKeys.hapticsEnabled)
            if isEnabled {
                warmUp()
                DispatchQueue.main.async { [weak self] in
                    self?.testBurst()
                }
            }
        }
    }

    private init() {
        supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.hapticsEnabled) == nil {
            _isEnabled = true
        } else {
            _isEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hapticsEnabled)
        }
        warmUp()
    }

    func toggle() {
        isEnabled.toggle()
    }

    func warmUp() {
        light.prepare()
        soft.prepare()
        medium.prepare()
        heavy.prepare()
        rigid.prepare()
        selection.prepare()
        notification.prepare()
        startEngine()
    }

    /// Alias used by call sites.
    func prepare() { warmUp() }

    // MARK: - Public cues (all maxed)

    func tap() {
        guard isEnabled else { return }
        warmUp()
        system(systemPeek)
        heavy.impactOccurred(intensity: 1.0)
        rigid.impactOccurred(intensity: 1.0)
        playCore([
            .hit(time: 0, intensity: 1, sharpness: 0.7),
            .rumble(time: 0, duration: 0.08, intensity: 0.8, sharpness: 0.4)
        ])
    }

    func select() {
        guard isEnabled else { return }
        warmUp()
        system(systemPeek)
        selection.selectionChanged()
        heavy.impactOccurred(intensity: 1.0)
        playCore([
            .hit(time: 0, intensity: 1, sharpness: 0.55),
            .hit(time: 0.05, intensity: 0.85, sharpness: 0.8)
        ])
    }

    func navigate() {
        guard isEnabled else { return }
        warmUp()
        system(systemPop)
        heavy.impactOccurred(intensity: 1.0)
        rigid.impactOccurred(intensity: 1.0)
        medium.impactOccurred(intensity: 1.0)
        playCore([
            .hit(time: 0, intensity: 1, sharpness: 0.85),
            .rumble(time: 0.02, duration: 0.12, intensity: 0.9, sharpness: 0.5),
            .hit(time: 0.1, intensity: 1, sharpness: 1)
        ])
    }

    func pressDown() {
        guard isEnabled else { return }
        warmUp()
        system(systemPeek)
        rigid.impactOccurred(intensity: 1.0)
        heavy.impactOccurred(intensity: 0.9)
    }

    func levelStart() {
        guard isEnabled else { return }
        warmUp()
        system(systemPop)
        pulse(count: 3, spacing: 0.09) {
            self.heavy.impactOccurred(intensity: 1.0)
            self.rigid.impactOccurred(intensity: 1.0)
        }
        playCore([
            .rumble(time: 0, duration: 0.18, intensity: 0.9, sharpness: 0.35),
            .hit(time: 0.06, intensity: 1, sharpness: 0.7),
            .hit(time: 0.14, intensity: 1, sharpness: 1),
            .hit(time: 0.22, intensity: 0.9, sharpness: 0.85)
        ])
    }

    func correct(step: Int, total: Int) {
        guard isEnabled else { return }
        warmUp()
        let progress = total > 0 ? Float(step) / Float(max(total, 1)) : 1
        system(systemPop)
        notification.notificationOccurred(.success)
        heavy.impactOccurred(intensity: 1.0)
        rigid.impactOccurred(intensity: 1.0)

        // Extra hits that ramp with progress — last bead should feel huge.
        let extra = progress > 0.5 ? 2 : 1
        pulse(count: extra, spacing: 0.07) {
            self.heavy.impactOccurred(intensity: 1.0)
            self.light.impactOccurred(intensity: 1.0)
        }
        if progress > 0.85 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                guard let self, self.isEnabled else { return }
                self.system(self.systemPop)
                self.heavy.impactOccurred(intensity: 1.0)
                self.rigid.impactOccurred(intensity: 1.0)
                self.notification.notificationOccurred(.success)
            }
        }

        playCore([
            .hit(time: 0, intensity: 1, sharpness: 0.7),
            .rumble(time: 0.01, duration: 0.14, intensity: 1, sharpness: 0.45),
            .hit(time: 0.06, intensity: 1, sharpness: 1),
            .hit(time: 0.12, intensity: 0.9 + 0.1 * progress, sharpness: 1),
            .hit(time: 0.2, intensity: 1, sharpness: 0.9)
        ])
    }

    func combo(count: Int) {
        guard isEnabled, count >= 2 else { return }
        warmUp()
        system(systemPop)
        pulse(count: min(count, 5), spacing: 0.06) {
            self.heavy.impactOccurred(intensity: 1.0)
            self.rigid.impactOccurred(intensity: 1.0)
        }
        playCore([
            .hit(time: 0, intensity: 1, sharpness: 1),
            .hit(time: 0.06, intensity: 1, sharpness: 0.8),
            .rumble(time: 0.08, duration: 0.16, intensity: 1, sharpness: 0.6),
            .hit(time: 0.18, intensity: 1, sharpness: 1)
        ])
    }

    func wrong() {
        guard isEnabled else { return }
        warmUp()
        // Still noticeable, but not scary — soft double thud + system nope.
        system(systemNope)
        soft.impactOccurred(intensity: 0.85)
        medium.impactOccurred(intensity: 0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.soft.impactOccurred(intensity: 0.6)
        }
        playCore([
            .hit(time: 0, intensity: 0.7, sharpness: 0.15),
            .hit(time: 0.1, intensity: 0.55, sharpness: 0.1)
        ])
    }

    func celebrate(stars: Int) {
        guard isEnabled else { return }
        warmUp()
        system(systemPop)
        notification.notificationOccurred(.success)

        // ~1.6s of hard hits — the big payoff.
        let beats = 12 + stars * 2
        pulse(count: beats, spacing: 0.09) {
            self.heavy.impactOccurred(intensity: 1.0)
            self.rigid.impactOccurred(intensity: 1.0)
            if Bool.random() {
                self.system(self.systemPop)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.notification.notificationOccurred(.success)
        }
        if stars >= 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
                guard let self, self.isEnabled else { return }
                self.system(self.systemPop)
                self.notification.notificationOccurred(.success)
                self.heavy.impactOccurred(intensity: 1.0)
                self.rigid.impactOccurred(intensity: 1.0)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }

        var events: [CHHapticEvent] = []
        for i in 0..<beats {
            let t = Double(i) * 0.09
            events.append(.hit(time: t, intensity: 1, sharpness: i.isMultiple(of: 2) ? 1 : 0.7))
            if i.isMultiple(of: 3) {
                events.append(.rumble(time: t, duration: 0.1, intensity: 1, sharpness: 0.5))
            }
        }
        playCore(events)
    }

    func starPop(index: Int) {
        guard isEnabled else { return }
        warmUp()
        system(systemPop)
        heavy.impactOccurred(intensity: 1.0)
        rigid.impactOccurred(intensity: 1.0)
        light.impactOccurred(intensity: 1.0)
        playCore([
            .hit(time: 0, intensity: 1, sharpness: 1),
            .rumble(time: 0.02, duration: 0.1, intensity: 0.9, sharpness: 0.7),
            .hit(time: 0.08, intensity: 1, sharpness: 0.9)
        ])
    }

    func unlock() {
        guard isEnabled else { return }
        warmUp()
        system(systemPop)
        notification.notificationOccurred(.success)
        pulse(count: 4, spacing: 0.08) {
            self.heavy.impactOccurred(intensity: 1.0)
            self.rigid.impactOccurred(intensity: 1.0)
        }
        playCore([
            .rumble(time: 0, duration: 0.16, intensity: 1, sharpness: 0.4),
            .hit(time: 0.06, intensity: 1, sharpness: 0.85),
            .hit(time: 0.14, intensity: 1, sharpness: 1),
            .hit(time: 0.24, intensity: 1, sharpness: 0.9)
        ])
    }

    func welcome() {
        guard isEnabled else { return }
        warmUp()
        system(systemPeek)
        pulse(count: 3, spacing: 0.1) {
            self.heavy.impactOccurred(intensity: 1.0)
        }
        playCore([
            .hit(time: 0, intensity: 0.9, sharpness: 0.5),
            .hit(time: 0.1, intensity: 1, sharpness: 0.7),
            .hit(time: 0.2, intensity: 1, sharpness: 0.9)
        ])
    }

    /// Big obvious blast for the "Feel That?" control.
    func testBurst() {
        guard isEnabled else { return }
        warmUp()
        system(systemPop)
        notification.notificationOccurred(.success)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        pulse(count: 8, spacing: 0.08) {
            self.heavy.impactOccurred(intensity: 1.0)
            self.rigid.impactOccurred(intensity: 1.0)
            self.medium.impactOccurred(intensity: 1.0)
        }
        playCore([
            .rumble(time: 0, duration: 0.35, intensity: 1, sharpness: 0.6),
            .hit(time: 0.05, intensity: 1, sharpness: 1),
            .hit(time: 0.12, intensity: 1, sharpness: 0.8),
            .hit(time: 0.2, intensity: 1, sharpness: 1),
            .hit(time: 0.28, intensity: 1, sharpness: 0.9),
            .hit(time: 0.36, intensity: 1, sharpness: 1),
            .hit(time: 0.48, intensity: 1, sharpness: 1)
        ])
    }

    // MARK: - Internals

    private func system(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }

    private func pulse(count: Int, spacing: TimeInterval, beat: @escaping () -> Void) {
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * spacing) { [weak self] in
                guard let self, self.isEnabled else { return }
                beat()
            }
        }
    }

    private func startEngine() {
        guard supportsCoreHaptics else { return }
        if engine == nil {
            do {
                let newEngine = try CHHapticEngine()
                newEngine.isAutoShutdownEnabled = false
                newEngine.playsHapticsOnly = true
                newEngine.resetHandler = { [weak self] in
                    try? self?.engine?.start()
                }
                newEngine.stoppedHandler = { [weak self] _ in
                    try? self?.engine?.start()
                }
                engine = newEngine
            } catch {
                supportsCoreHaptics = false
                return
            }
        }
        do {
            try engine?.start()
        } catch {
            // UIKit + system sounds still fire.
        }
    }

    private func playCore(_ events: [CHHapticEvent]) {
        guard supportsCoreHaptics, let engine else { return }
        do {
            try engine.start()
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            try? engine.start()
        }
    }
}

private extension CHHapticEvent {
    static func hit(time: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: min(1, intensity)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: min(1, sharpness))
            ],
            relativeTime: time
        )
    }

    static func rumble(time: TimeInterval, duration: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: min(1, intensity)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: min(1, sharpness))
            ],
            relativeTime: time,
            duration: duration
        )
    }
}
