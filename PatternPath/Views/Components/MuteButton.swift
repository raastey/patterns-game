import SwiftUI

struct MuteButton: View {
    private var sound = SoundPlayer.shared

    var body: some View {
        Button {
            HapticsPlayer.shared.tap()
            sound.toggleMute()
        } label: {
            Image(systemName: sound.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Circle().fill(Color.white.opacity(0.3))
                        }
                        .overlay {
                            Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                        }
                        .shadow(color: AppTheme.ink.opacity(0.06), radius: 8, y: 3)
                }
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(PremiumPressStyle())
        .accessibilityLabel(sound.isMuted ? "Sound off" : "Sound on")
        .accessibilityHint("Turns game sounds on or off")
    }
}
