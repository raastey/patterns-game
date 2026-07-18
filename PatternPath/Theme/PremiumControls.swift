import SwiftUI

struct PrimaryCTA: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    @State private var pressCount = 0

    var body: some View {
        Button {
            pressCount += 1
            HapticsPlayer.shared.navigate()
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .bold))
                        .symbolEffect(.bounce, value: pressCount)
                }
                Text(title)
                    .font(.display(22, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background {
                Capsule(style: .continuous)
                    .fill(AppTheme.accentGradient)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.accent.opacity(0.45), radius: 20, y: 10)
                    .shadow(color: AppTheme.accentDeep.opacity(0.2), radius: 4, y: 2)
            }
        }
        .buttonStyle(PremiumPressStyle())
    }
}

struct SecondaryCTA: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            HapticsPlayer.shared.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                }
                Text(title)
                    .font(.bodyRounded(19, weight: .semibold))
            }
            .foregroundStyle(AppTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.4))
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(PremiumPressStyle())
    }
}

struct ToolbarChip: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            HapticsPlayer.shared.tap()
            action()
        } label: {
            HStack(spacing: 7) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.bodyRounded(16, weight: .semibold))
            }
            .foregroundStyle(AppTheme.ink)
            .glassChip()
        }
        .buttonStyle(PremiumPressStyle())
    }
}

struct StatusChip: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = AppTheme.ink

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(tint)
            }
            Text(text)
                .font(.bodyRounded(16, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .monospacedDigit()
        }
        .glassChip()
    }
}

struct FocusBadge: View {
    let focus: PatternFocus

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: focus == .color ? "paintpalette.fill" : "square.on.circle.fill")
                .font(.system(size: 14, weight: .bold))
            Text(focus.prompt)
                .font(.bodyRounded(17, weight: .bold))
        }
        .foregroundStyle(AppTheme.accentDeep)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            Capsule(style: .continuous)
                .fill(AppTheme.accent.opacity(0.12))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(AppTheme.accent.opacity(0.22), lineWidth: 1)
                }
        }
    }
}

struct PremiumPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(Motion.snappy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    HapticsPlayer.shared.pressDown()
                }
            }
    }
}

/// Backward-compatible alias used by existing call sites.
typealias BounceButtonStyle = PremiumPressStyle
