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
            // Soft contact shadow
            if showsShadow {
                TokenShapeView(shape: token.shape)
                    .fill(token.hue.color.opacity(0.35))
                    .blur(radius: size * 0.12)
                    .offset(y: size * 0.08)
                    .scaleEffect(0.92)
            }

            // Body
            TokenShapeView(shape: token.shape)
                .fill(
                    LinearGradient(
                        colors: [
                            token.hue.color.lighten(0.12),
                            token.hue.color,
                            token.hue.color.darken(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    // Specular glass cap
                    TokenShapeView(shape: token.shape)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .scaleEffect(x: 0.78, y: 0.62)
                        .offset(y: -size * 0.1)
                        .blur(radius: 0.5)
                }
                .overlay {
                    // Rim light
                    TokenShapeView(shape: token.shape)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.85),
                                    Color.white.opacity(0.15),
                                    token.hue.color.darken(0.2).opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1.5, size * 0.045)
                        )
                }
                .shadow(
                    color: showsShadow ? token.hue.color.opacity(isSelected || isPlaced ? 0.45 : 0.28) : .clear,
                    radius: isSelected || isPlaced ? size * 0.18 : size * 0.1,
                    y: isSelected || isPlaced ? size * 0.08 : size * 0.04
                )
        }
        .frame(width: size, height: size)
        .scaleEffect(isSelected ? 1.08 : (isPlaced ? 1.05 : 1.0))
        .opacity(isDimmed ? 0.4 : 1.0)
        .accessibilityLabel(token.accessibilityLabel)
    }
}

private extension Color {
    func lighten(_ amount: CGFloat) -> Color {
        mixed(with: .white, amount: amount)
    }

    func darken(_ amount: CGFloat) -> Color {
        mixed(with: .black, amount: amount)
    }

    func mixed(with other: Color, amount: CGFloat) -> Color {
        let a = UIColor(self)
        let b = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * amount,
            green: g1 + (g2 - g1) * amount,
            blue: b1 + (b2 - b1) * amount,
            opacity: a1 + (a2 - a1) * amount
        )
    }
}

struct TokenShapeView: Shape {
    let shape: TokenShape

    func path(in rect: CGRect) -> Path {
        switch shape {
        case .circle:
            return Circle().path(in: rect)
        case .square:
            let inset = rect.width * 0.08
            return RoundedRectangle(cornerRadius: rect.width * 0.2, style: .continuous)
                .path(in: rect.insetBy(dx: inset, dy: inset))
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.08))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.maxY - rect.height * 0.1))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY - rect.height * 0.1))
            path.closeSubpath()
            return path
        case .star:
            return starPath(in: rect, points: 5)
        case .hexagon:
            return polygon(in: rect, sides: 6)
        case .diamond:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.06))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.06))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY))
            path.closeSubpath()
            return path
        }
    }

    private func polygon(in rect: CGRect, sides: Int) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.42
        var path = Path()
        for i in 0..<sides {
            let angle = (Double(i) / Double(sides)) * Double.pi * 2 - Double.pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    private func starPath(in rect: CGRect, points: Int) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) * 0.44
        let inner = outer * 0.42
        var path = Path()
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = (Double(i) / Double(points * 2)) * Double.pi * 2 - Double.pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
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
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(Color.white.opacity(isActive ? 0.42 : 0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: size * 0.055,
                                dash: [size * 0.14, size * 0.1]
                            )
                        )
                        .foregroundStyle(
                            isActive
                                ? AnyShapeStyle(AppTheme.accent.opacity(0.85))
                                : AnyShapeStyle(AppTheme.inkFaint.opacity(0.45))
                        )
                }
                .shadow(color: isActive ? AppTheme.accent.opacity(0.2) : .clear, radius: 12, y: 4)

            if isActive {
                Image(systemName: "plus")
                    .font(.system(size: size * 0.28, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.accent.opacity(0.55))
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
        .accessibilityLabel(isActive ? "Empty spot, waiting for a bead" : "Empty spot")
    }

    private func startPulseIfNeeded() {
        pulse = false
        guard isActive, !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}
