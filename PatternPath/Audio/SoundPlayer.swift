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
    case check

    var volume: Float {
        switch self {
        case .complete, .reward, .levelUp, .achievement: 0.55
        case .bonus, .streak: 0.48
        case .success, .drop: 0.45
        case .undo: 0.32
        case .select, .press, .check: 0.38
        case .play, .start, .unlock, .notification, .badge: 0.42
        }
    }
}

@Observable
final class SoundPlayer {
    static let shared = SoundPlayer()

    private var players: [String: AVAudioPlayer] = [:]
    private var audioReady = false

    var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: UserDefaultsKeys.soundMuted)
        }
    }

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundMuted)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.play(.success)
        }
    }

    func playWrong() {
        play(.undo)
    }

    func playUndo() {
        play(.press)
    }

    func playCelebrate() {
        play(.complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
            self?.play(.reward)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.play(.achievement)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in
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
            .start, .unlock, .undo, .streak, .bonus, .achievement, .notification, .play, .badge, .check
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
