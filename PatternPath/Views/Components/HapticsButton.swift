import SwiftUI

struct HapticsButton: View {
    private let haptics = HapticsPlayer.shared

    var body: some View {
        Button {
            haptics.toggle()
        } label: {
            Image(systemName: haptics.isEnabled ? "hand.tap.fill" : "hand.tap")
                .font(.system(size: 16, weight: .semibold))
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
                                haptics.isEnabled ? AppTheme.accent.opacity(0.35) : Color.white.opacity(0.5),
                                lineWidth: 1
                            )
                        }
                        .shadow(color: AppTheme.ink.opacity(0.06), radius: 8, y: 3)
                }
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(PremiumPressStyle())
        .accessibilityLabel(haptics.isEnabled ? "Haptics on" : "Haptics off")
        .accessibilityHint("Turns touch vibrations on or off")
    }
}
