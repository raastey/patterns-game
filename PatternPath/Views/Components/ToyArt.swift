import SwiftUI

/// Kenney CC0 3D vehicle renders on a glossy garage pad.
/// Pad color carries the hue attribute; the model stays readable.
struct ToyArt: View {
    let toy: ToyKind
    let hue: TokenHue
    var size: CGFloat = 72

    private var paint: Color { hue.color }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            paint.lighten(0.22),
                            paint,
                            paint.darken(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.55), lineWidth: size * 0.04)
                }

            Image(toy.assetName)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: size * 0.9, height: size * 0.8)
                .shadow(color: .black.opacity(0.28), radius: size * 0.045, y: size * 0.035)
        }
        .frame(width: size, height: size)
    }
}

extension ToyKind {
    var assetName: String {
        switch self {
        case .raceCar: "ToyraceCar"
        case .fireTruck: "ToyfireTruck"
        case .policeCar: "ToypoliceCar"
        case .dumpTruck: "ToydumpTruck"
        case .carCarrier: "ToycarCarrier"
        case .robot: "Toyrobot"
        case .ambulance: "Toyambulance"
        case .rocket: "Toyrocket"
        }
    }
}

extension Color {
    func lighten(_ amount: CGFloat) -> Color { mixed(with: .white, amount: amount) }
    func darken(_ amount: CGFloat) -> Color { mixed(with: .black, amount: amount) }

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
