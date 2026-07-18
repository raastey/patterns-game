import AVFoundation
import Foundation

enum GameSound: String {
    case drop
    case success
    case check
    case complete
    case reward
    case levelUp = "level-up"
    case select
    case press
    case start
    case unlock
    case undo
    case softDeselect = "soft_deselect"

    var volume: Float {
        switch self {
        case .complete, .reward, .levelUp: 0.55
        case .undo, .softDeselect: 0.35
        case .drop, .success, .check: 0.45
        default: 0.4
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
    }

    func playWrong() {
        play(.undo)
    }

    func playCelebrate() {
        play(.complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.play(.reward)
        }
    }

    func playTap() {
        play(.select)
    }

    func playLevelStart() {
        play(.start)
    }

    private func configureSession() {
        guard !audioReady else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            audioReady = true
        } catch {
            // Ambient audio is best-effort; gameplay continues silently.
        }
    }

    private func preload() {
        let names = [
            GameSound.drop, .success, .check, .complete, .reward,
            .levelUp, .select, .press, .start, .unlock, .undo, .softDeselect
        ]
        for sound in names {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
                continue
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[sound.rawValue] = player
            } catch {
                continue
            }
        }
    }
}
