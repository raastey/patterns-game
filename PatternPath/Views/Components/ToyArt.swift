import SwiftUI

/// Chunky, glossy toy illustrations — readable at small sizes, tintable by hue.
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
                            paint.lighten(0.18),
                            paint,
                            paint.darken(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.55), lineWidth: size * 0.04)
                }

            toyGlyph
                .frame(width: size * 0.78, height: size * 0.62)
                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var toyGlyph: some View {
        switch toy {
        case .raceCar: RaceCarGlyph(paint: paint)
        case .fireTruck: FireTruckGlyph(paint: paint)
        case .policeCar: PoliceCarGlyph(paint: paint)
        case .dumpTruck: DumpTruckGlyph(paint: paint)
        case .carCarrier: CarCarrierGlyph(paint: paint)
        case .robot: RobotGlyph(paint: paint)
        case .ambulance: AmbulanceGlyph(paint: paint)
        case .rocket: RocketGlyph(paint: paint)
        }
    }
}

// MARK: - Glyphs

private struct RaceCarGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // body
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.92, height: h * 0.38)
                    .offset(y: h * 0.08)
                // cabin
                RoundedRectangle(cornerRadius: w * 0.12, style: .continuous)
                    .fill(paint.darken(0.1).opacity(0.85))
                    .frame(width: w * 0.42, height: h * 0.28)
                    .offset(x: -w * 0.06, y: -h * 0.12)
                // stripe
                Capsule()
                    .fill(paint)
                    .frame(width: w * 0.7, height: h * 0.08)
                    .offset(y: h * 0.05)
                wheel(at: CGPoint(x: w * 0.22, y: h * 0.72), r: w * 0.12)
                wheel(at: CGPoint(x: w * 0.78, y: h * 0.72), r: w * 0.12)
                // spoiler
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: w * 0.18, height: h * 0.1)
                    .offset(x: w * 0.32, y: -h * 0.18)
            }
            .frame(width: w, height: h)
        }
    }

    private func wheel(at point: CGPoint, r: CGFloat) -> some View {
        Circle()
            .fill(Color(white: 0.15))
            .frame(width: r * 2, height: r * 2)
            .overlay { Circle().fill(Color.white.opacity(0.35)).frame(width: r * 0.7, height: r * 0.7) }
            .position(point)
    }
}

private struct FireTruckGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // cab
                RoundedRectangle(cornerRadius: w * 0.1, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.38, height: h * 0.42)
                    .offset(x: -w * 0.26, y: h * 0.02)
                // ladder bed
                RoundedRectangle(cornerRadius: w * 0.08, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.55, height: h * 0.32)
                    .offset(x: w * 0.18, y: h * 0.08)
                // ladder
                Capsule().fill(paint.darken(0.05)).frame(width: w * 0.48, height: h * 0.07).offset(x: w * 0.16, y: -h * 0.08)
                Capsule().fill(paint.darken(0.05)).frame(width: w * 0.48, height: h * 0.07).offset(x: w * 0.16, y: -h * 0.18)
                // light bar
                Capsule().fill(paint).frame(width: w * 0.22, height: h * 0.08).offset(x: -w * 0.26, y: -h * 0.22)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.16, height: w * 0.16).offset(x: -w * 0.28, y: h * 0.32)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.16, height: w * 0.16).offset(x: w * 0.08, y: h * 0.32)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.16, height: w * 0.16).offset(x: w * 0.32, y: h * 0.32)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct PoliceCarGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.9, height: h * 0.36)
                    .offset(y: h * 0.1)
                RoundedRectangle(cornerRadius: w * 0.1, style: .continuous)
                    .fill(paint.opacity(0.35))
                    .frame(width: w * 0.4, height: h * 0.26)
                    .offset(y: -h * 0.1)
                // light bar
                HStack(spacing: 2) {
                    Capsule().fill(Color.red.opacity(0.9))
                    Capsule().fill(Color.blue.opacity(0.9))
                }
                .frame(width: w * 0.28, height: h * 0.1)
                .offset(y: -h * 0.28)
                // badge star
                Image(systemName: "star.fill")
                    .font(.system(size: w * 0.14, weight: .bold))
                    .foregroundStyle(paint)
                    .offset(y: h * 0.08)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.18).offset(x: -w * 0.28, y: h * 0.35)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.18).offset(x: w * 0.28, y: h * 0.35)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct DumpTruckGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // cab
                RoundedRectangle(cornerRadius: w * 0.1, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.34, height: h * 0.4)
                    .offset(x: -w * 0.28, y: h * 0.05)
                // dump bed tipped look
                RoundedRectangle(cornerRadius: w * 0.08, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.52, height: h * 0.36)
                    .rotationEffect(.degrees(-8))
                    .offset(x: w * 0.18, y: h * 0.02)
                // dirt pile
                Capsule().fill(paint.opacity(0.7)).frame(width: w * 0.28, height: h * 0.14).offset(x: w * 0.16, y: -h * 0.12)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.17).offset(x: -w * 0.28, y: h * 0.35)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.2).offset(x: w * 0.1, y: h * 0.34)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.2).offset(x: w * 0.34, y: h * 0.34)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct CarCarrierGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // long deck
                RoundedRectangle(cornerRadius: w * 0.08, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.92, height: h * 0.22)
                    .offset(y: h * 0.18)
                // cab
                RoundedRectangle(cornerRadius: w * 0.1, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.28, height: h * 0.36)
                    .offset(x: -w * 0.32, y: -h * 0.02)
                // upper ramp cars
                Capsule().fill(paint.opacity(0.85)).frame(width: w * 0.22, height: h * 0.12).offset(x: -0.02 * w, y: -h * 0.18)
                Capsule().fill(paint.opacity(0.65)).frame(width: w * 0.22, height: h * 0.12).offset(x: w * 0.28, y: -h * 0.18)
                Capsule().fill(paint.opacity(0.75)).frame(width: w * 0.22, height: h * 0.12).offset(x: w * 0.12, y: h * 0.08)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.14).offset(x: -w * 0.32, y: h * 0.38)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.14).offset(x: w * 0.05, y: h * 0.38)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.14).offset(x: w * 0.32, y: h * 0.38)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct RobotGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // antenna
                Capsule().fill(Color.white).frame(width: w * 0.06, height: h * 0.18).offset(y: -h * 0.4)
                Circle().fill(paint).frame(width: w * 0.1).offset(y: -h * 0.5)
                // head
                RoundedRectangle(cornerRadius: w * 0.12, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.48, height: h * 0.32)
                    .offset(y: -h * 0.18)
                // eyes
                HStack(spacing: w * 0.08) {
                    Circle().fill(paint).frame(width: w * 0.1)
                    Circle().fill(paint).frame(width: w * 0.1)
                }
                .offset(y: -h * 0.2)
                // body
                RoundedRectangle(cornerRadius: w * 0.12, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.55, height: h * 0.38)
                    .offset(y: h * 0.18)
                // chest light
                RoundedRectangle(cornerRadius: 3)
                    .fill(paint)
                    .frame(width: w * 0.22, height: h * 0.1)
                    .offset(y: h * 0.14)
                // arms
                Capsule().fill(Color.white.opacity(0.95)).frame(width: w * 0.12, height: h * 0.28).offset(x: -w * 0.38, y: h * 0.12)
                Capsule().fill(Color.white.opacity(0.95)).frame(width: w * 0.12, height: h * 0.28).offset(x: w * 0.38, y: h * 0.12)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct AmbulanceGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.1, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.88, height: h * 0.42)
                    .offset(y: h * 0.06)
                // cab window
                RoundedRectangle(cornerRadius: 4)
                    .fill(paint.opacity(0.35))
                    .frame(width: w * 0.22, height: h * 0.18)
                    .offset(x: -w * 0.28, y: -h * 0.02)
                // cross
                Capsule().fill(paint).frame(width: w * 0.08, height: h * 0.28).offset(x: w * 0.12, y: h * 0.02)
                Capsule().fill(paint).frame(width: w * 0.28, height: h * 0.08).offset(x: w * 0.12, y: h * 0.02)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.16).offset(x: -w * 0.28, y: h * 0.36)
                Circle().fill(Color(white: 0.15)).frame(width: w * 0.16).offset(x: w * 0.28, y: h * 0.36)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct RocketGlyph: View {
    let paint: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // fins
                Triangle()
                    .fill(paint.opacity(0.85))
                    .frame(width: w * 0.28, height: h * 0.22)
                    .rotationEffect(.degrees(-25))
                    .offset(x: -w * 0.28, y: h * 0.28)
                Triangle()
                    .fill(paint.opacity(0.85))
                    .frame(width: w * 0.28, height: h * 0.22)
                    .rotationEffect(.degrees(25))
                    .offset(x: w * 0.28, y: h * 0.28)
                // body
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: w * 0.36, height: h * 0.78)
                    .offset(y: h * 0.04)
                // nose
                Circle()
                    .fill(paint)
                    .frame(width: w * 0.36, height: w * 0.36)
                    .offset(y: -h * 0.32)
                // window
                Circle()
                    .fill(paint.opacity(0.45))
                    .overlay { Circle().strokeBorder(Color.white, lineWidth: 2) }
                    .frame(width: w * 0.16)
                    .offset(y: -h * 0.05)
                // flame
                Capsule().fill(paint.lighten(0.2)).frame(width: w * 0.14, height: h * 0.16).offset(y: h * 0.48)
            }
            .frame(width: w, height: h)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
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
