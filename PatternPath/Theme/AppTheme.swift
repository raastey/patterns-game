import SwiftUI

enum AppTheme {
    // Atmosphere — cool mist into warm sand, not cream/terracotta default
    static let mistDeep = Color(red: 0.42, green: 0.72, blue: 0.78)
    static let mistMid = Color(red: 0.72, green: 0.88, blue: 0.86)
    static let mistLight = Color(red: 0.93, green: 0.95, blue: 0.92)
    static let sandGlow = Color(red: 0.98, green: 0.91, blue: 0.78)
    static let bloomApricot = Color(red: 1.0, green: 0.72, blue: 0.52)
    static let bloomMint = Color(red: 0.55, green: 0.88, blue: 0.74)

    // Chrome
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.22)
    static let inkSoft = Color(red: 0.32, green: 0.38, blue: 0.46)
    static let inkFaint = Color(red: 0.48, green: 0.54, blue: 0.60)
    static let surface = Color.white.opacity(0.72)
    static let surfaceSolid = Color(red: 0.99, green: 0.99, blue: 0.985)
    static let stroke = Color.white.opacity(0.55)
    static let strokeSoft = Color.white.opacity(0.28)

    // Path tray — smoked oak, refined
    static let trayLight = Color(red: 0.82, green: 0.68, blue: 0.52)
    static let trayMid = Color(red: 0.68, green: 0.50, blue: 0.36)
    static let trayDeep = Color(red: 0.52, green: 0.36, blue: 0.26)

    static let accent = Color(red: 0.12, green: 0.58, blue: 0.56)
    static let accentDeep = Color(red: 0.08, green: 0.45, blue: 0.44)
    static let success = Color(red: 0.20, green: 0.70, blue: 0.48)
    static let star = Color(red: 1.0, green: 0.76, blue: 0.20)

    // Beads
    static let coral = Color(red: 0.96, green: 0.40, blue: 0.38)
    static let teal = Color(red: 0.14, green: 0.60, blue: 0.56)
    static let sunflower = Color(red: 0.98, green: 0.76, blue: 0.20)
    static let periwinkle = Color(red: 0.40, green: 0.50, blue: 0.92)
    static let mint = Color(red: 0.38, green: 0.80, blue: 0.60)
    static let apricot = Color(red: 0.98, green: 0.60, blue: 0.36)

    static var trayGradient: LinearGradient {
        LinearGradient(
            colors: [trayLight, trayMid, trayDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.95), accentDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Legacy aliases used across views
    static var skyGradient: LinearGradient {
        LinearGradient(
            colors: [mistDeep, mistMid, sandGlow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var pathGradient: LinearGradient { trayGradient }
    static var card: Color { surface }
    static var cream: Color { surfaceSolid }
    static var pathWood: Color { trayMid }
    static var pathWoodLight: Color { trayLight }
    static var skyTop: Color { mistDeep }
    static var skyMid: Color { mistMid }
    static var skyBottom: Color { sandGlow }
}

extension Font {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func bodyRounded(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func captionRounded(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

enum Motion {
    static let softSpring = Animation.spring(response: 0.55, dampingFraction: 0.84)
    static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.72)
    static let bouncy = Animation.spring(response: 0.42, dampingFraction: 0.62)
}

struct GlassSurface: ViewModifier {
    var cornerRadius: CGFloat = 28
    var intense: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(intense ? 0.35 : 0.18))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: AppTheme.ink.opacity(0.08), radius: 24, y: 10)
                    .shadow(color: AppTheme.ink.opacity(0.04), radius: 4, y: 1)
            }
    }
}

struct GlassChip: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.28))
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.ink.opacity(0.06), radius: 10, y: 4)
            }
    }
}

extension View {
    func glassSurface(cornerRadius: CGFloat = 28, intense: Bool = false) -> some View {
        modifier(GlassSurface(cornerRadius: cornerRadius, intense: intense))
    }

    func glassChip() -> some View {
        modifier(GlassChip())
    }
}
