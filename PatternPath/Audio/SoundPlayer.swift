import AVFoundation
import Foundation

enum GameSound: String {
    case drop
    case success
    case complete
    case reward
    case levelUp = "level-up"
    case select
    case press
    case start
    case unlock
    case undo
    case streak
    case bonus
    case achievement
    case notification
    case play
    case badge

    var volume: Float {
        switch self {
        case .complete, .reward, .levelUp, .achievement, .bonus, .streak: 0.7
        case .undo: 0.4
        case .drop, .success, .select, .press: 0.55
        default: 0.5
        }
    }
}

@Observable
final class SoundPlayer {
    static let shared = SoundPlayer()

    private let muteKey = "patternpath.soundMuted"
    private var players: [String: AVAudioPlayer] = [:]
    private var audioReady = false

    var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: muteKey)
        }
    }

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: muteKey)
        configureSession()
        preload()
    }

    func toggleMute() {
        isMuted.toggle()
        if !isMuted {
            play(.select)
        }
    }

    func play(_ sound: GameSound) {
        guard !isMuted else { return }
        configureSession()
        guard let player = players[sound.rawValue] else { return }
        player.volume = sound.volume
        player.currentTime = 0
        player.play()
    }

    func playCorrect() {
        play(.drop)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.play(.success)
        }
    }

    func playWrong() {
        play(.undo)
    }

    func playCelebrate() {
        play(.complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.play(.reward)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.play(.achievement)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.play(.bonus)
        }
    }

    func playStreak() {
        play(.streak)
    }

    func playTap() {
        play(.select)
    }

    func playLevelStart() {
        play(.play)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.play(.start)
        }
    }

    private func configureSession() {
        guard !audioReady else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            audioReady = true
        } catch {}
    }

    private func preload() {
        for sound in [
            GameSound.drop, .success, .complete, .reward, .levelUp, .select, .press,
            .start, .unlock, .undo, .streak, .bonus, .achievement, .notification, .play, .badge
        ] {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
                continue
            }
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                players[sound.rawValue] = player
            }
        }
    }
}
