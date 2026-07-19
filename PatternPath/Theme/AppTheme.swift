import SwiftUI

enum AppTheme {
    // Garage bay atmosphere — cool concrete into warm shop light
    static let mistDeep = Color(red: 0.28, green: 0.42, blue: 0.52)
    static let mistMid = Color(red: 0.48, green: 0.62, blue: 0.68)
    static let mistLight = Color(red: 0.78, green: 0.84, blue: 0.86)
    static let sandGlow = Color(red: 0.92, green: 0.86, blue: 0.72)
    static let bloomApricot = Color(red: 1.0, green: 0.62, blue: 0.28)
    static let bloomMint = Color(red: 0.35, green: 0.82, blue: 0.58)

    // Chrome
    static let ink = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let inkSoft = Color(red: 0.28, green: 0.32, blue: 0.38)
    static let inkFaint = Color(red: 0.45, green: 0.50, blue: 0.56)
    static let surface = Color.white.opacity(0.88)
    static let surfaceSolid = Color(red: 0.97, green: 0.97, blue: 0.96)
    static let stroke = Color.white.opacity(0.45)
    static let strokeSoft = Color.white.opacity(0.22)

    // Parking lot asphalt
    static let trayLight = Color(red: 0.42, green: 0.44, blue: 0.48)
    static let trayMid = Color(red: 0.30, green: 0.32, blue: 0.36)
    static let trayDeep = Color(red: 0.20, green: 0.22, blue: 0.26)
    static let trayLine = Color(red: 0.95, green: 0.82, blue: 0.28)

    static let accent = Color(red: 0.98, green: 0.55, blue: 0.12)
    static let accentDeep = Color(red: 0.88, green: 0.38, blue: 0.08)
    static let success = Color(red: 0.18, green: 0.72, blue: 0.42)
    static let star = Color(red: 1.0, green: 0.78, blue: 0.18)

    // Toy pad hues — saturated for kids
    static let coral = Color(red: 0.96, green: 0.32, blue: 0.30)
    static let teal = Color(red: 0.10, green: 0.62, blue: 0.58)
    static let sunflower = Color(red: 0.98, green: 0.78, blue: 0.12)
    static let periwinkle = Color(red: 0.32, green: 0.45, blue: 0.95)
    static let mint = Color(red: 0.28, green: 0.82, blue: 0.52)
    static let apricot = Color(red: 0.98, green: 0.55, blue: 0.22)

    // Choice shelf
    static let shelfTop = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let shelfEdge = Color(red: 0.88, green: 0.72, blue: 0.42)

    static var trayGradient: LinearGradient {
        LinearGradient(
            colors: [trayLight, trayMid, trayDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

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
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.88))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.ink.opacity(0.10), radius: 8, y: 3)
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
