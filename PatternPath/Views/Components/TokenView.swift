import SwiftUI

struct TokenView: View {
    let token: PatternToken
    var size: CGFloat = 72
    var isSelected: Bool = false
    var isDimmed: Bool = false
    var showsShadow: Bool = true
    var isPlaced: Bool = false

    var body: some View {
        ZStack {
            if showsShadow {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(token.hue.color.opacity(0.35))
                    .blur(radius: size * 0.12)
                    .offset(y: size * 0.1)
                    .scaleEffect(0.9)
            }

            ToyArt(toy: token.toy, hue: token.hue, size: size)
                .shadow(
                    color: showsShadow ? token.hue.color.opacity(isSelected || isPlaced ? 0.45 : 0.25) : .clear,
                    radius: isSelected || isPlaced ? size * 0.16 : size * 0.08,
                    y: isSelected || isPlaced ? size * 0.08 : size * 0.04
                )
        }
        .frame(width: size, height: size)
        .scaleEffect(isSelected ? 1.1 : (isPlaced ? 1.06 : 1.0))
        .opacity(isDimmed ? 0.4 : 1.0)
        .accessibilityLabel(token.accessibilityLabel)
    }
}

struct BlankSlotView: View {
    var size: CGFloat = 72
    var isActive: Bool = false
    var isShaking: Bool = false

    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(Color.white.opacity(isActive ? 0.22 : 0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: size * 0.055,
                                dash: [size * 0.14, size * 0.1]
                            )
                        )
                        .foregroundStyle(
                            isActive
                                ? AnyShapeStyle(AppTheme.trayLine)
                                : AnyShapeStyle(Color.white.opacity(0.35))
                        )
                }
                .shadow(color: isActive ? AppTheme.trayLine.opacity(0.45) : .clear, radius: 12, y: 4)

            if isActive {
                Image(systemName: "plus")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.trayLine.opacity(0.9))
                    .scaleEffect(pulse ? 1.08 : 0.92)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(pulse && isActive && !reduceMotion ? 1.04 : 1.0)
        .offset(x: isShaking ? -7 : 0)
        .animation(
            isShaking
                ? .easeInOut(duration: 0.07).repeatCount(4, autoreverses: true)
                : .default,
            value: isShaking
        )
        .onAppear { startPulseIfNeeded() }
        .onChange(of: isActive) { _, _ in startPulseIfNeeded() }
        .accessibilityLabel(isActive ? "Empty parking spot" : "Empty spot")
    }

    private func startPulseIfNeeded() {
        pulse = false
        guard isActive, !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}
