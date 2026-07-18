import SwiftUI

struct HapticsButton: View {
    private let haptics = HapticsPlayer.shared

    var body: some View {
        Button {
            if haptics.isEnabled {
                haptics.testBurst()
            } else {
                haptics.toggle()
            }
        } label: {
            Image(systemName: haptics.isEnabled ? "waveform.circle.fill" : "waveform.circle")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(haptics.isEnabled ? AppTheme.accentDeep : AppTheme.ink)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Circle().fill(Color.white.opacity(0.3))
                        }
                        .overlay {
                            Circle().strokeBorder(
                                haptics.isEnabled ? AppTheme.accent.opacity(0.45) : Color.white.opacity(0.5),
                                lineWidth: 1.5
                            )
                        }
                        .shadow(color: AppTheme.ink.opacity(0.06), radius: 8, y: 3)
                }
                .contentTransition(.symbolEffect(.replace))
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.55).onEnded { _ in
                haptics.toggle()
            }
        )
        .buttonStyle(PremiumPressStyle())
        .accessibilityLabel(haptics.isEnabled ? "Test haptics" : "Haptics off")
        .accessibilityHint("Tap to feel a strong buzz. Press and hold to turn haptics on or off.")
    }
}
