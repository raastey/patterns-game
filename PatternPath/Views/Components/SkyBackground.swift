import SwiftUI

struct SkyBackground: View {
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
                        AppTheme.mistDeep, AppTheme.mistMid, Color(red: 0.55, green: 0.70, blue: 0.78),
                        AppTheme.mistMid, AppTheme.mistLight, AppTheme.sandGlow,
                        Color(red: 0.55, green: 0.58, blue: 0.62),
                        AppTheme.trayMid.opacity(0.85),
                        AppTheme.trayDeep.opacity(0.9)
                    ]
                )
                .ignoresSafeArea()
            } else {
                AppTheme.skyGradient.ignoresSafeArea()
            }

            GeometryReader { geo in
                // Shop light bloom
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.45), Color.white.opacity(0)],
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

                // Warm bay lamp
                Circle()
                    .fill(AppTheme.bloomApricot.opacity(0.32))
                    .frame(width: geo.size.width * 0.4)
                    .blur(radius: 48)
                    .offset(
                        x: geo.size.width * 0.62 + (drift ? -8 : 12),
                        y: geo.size.height * 0.08
                    )

                // Concrete floor wash at bottom
                LinearGradient(
                    colors: [
                        Color.clear,
                        AppTheme.trayMid.opacity(0.35),
                        AppTheme.trayDeep.opacity(0.55)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
