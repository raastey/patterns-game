import Foundation
import SwiftUI

/// App-level preferences that are not owned by audio/haptics players.
@Observable
final class AppSettings {
    private let defaults: UserDefaults

    var coachCompleted: Bool {
        didSet { defaults.set(coachCompleted, forKey: UserDefaultsKeys.coachCompleted) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        coachCompleted = defaults.bool(forKey: UserDefaultsKeys.coachCompleted)
    }

    func completeCoach() {
        guard !coachCompleted else { return }
        coachCompleted = true
    }

    var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}
