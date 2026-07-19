import SwiftUI

struct SkyBackground: View {
    var theme: WorldTheme = .colorGarage
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drift = false

    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ],
                    colors: [
                        theme.skyDeep, theme.skyMid, theme.skyLight,
                        theme.skyMid, theme.skyLight, theme.sand,
                        theme.trayMid.opacity(0.75),
                        theme.trayMid.opacity(0.88),
                        theme.trayDeep.opacity(0.95)
                    ]
                )
                .ignoresSafeArea()
            } else {
                theme.skyGradient.ignoresSafeArea()
            }

            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.42), Color.white.opacity(0)],
                            center: .center,
                            startRadius: 8,
                            endRadius: geo.size.width * 0.32
                        )
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(
                        x: geo.size.width * 0.15 + (drift ? 10 : -6),
                        y: -geo.size.height * 0.28
                    )

                Circle()
                    .fill(theme.lamp.opacity(0.34))
                    .frame(width: geo.size.width * 0.4)
                    .blur(radius: 48)
                    .offset(
                        x: geo.size.width * 0.62 + (drift ? -8 : 12),
                        y: geo.size.height * 0.08
                    )

                LinearGradient(
                    colors: [
                        Color.clear,
                        theme.trayMid.opacity(0.35),
                        theme.trayDeep.opacity(0.55)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.45), value: theme.id)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
