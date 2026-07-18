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
                        AppTheme.mistDeep, AppTheme.mistMid, AppTheme.bloomMint.opacity(0.85),
                        AppTheme.mistMid, AppTheme.mistLight, AppTheme.sandGlow,
                        AppTheme.sandGlow, AppTheme.bloomApricot.opacity(0.55), AppTheme.mistLight
                    ]
                )
                .ignoresSafeArea()
            } else {
                AppTheme.skyGradient.ignoresSafeArea()
            }

            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                            center: .center,
                            startRadius: 10,
                            endRadius: geo.size.width * 0.28
                        )
                    )
                    .frame(width: geo.size.width * 0.55)
                    .offset(
                        x: -geo.size.width * 0.1 + (drift ? 12 : -8),
                        y: -geo.size.height * 0.22
                    )

                Circle()
                    .fill(AppTheme.bloomApricot.opacity(0.28))
                    .frame(width: geo.size.width * 0.42)
                    .blur(radius: 50)
                    .offset(
                        x: geo.size.width * 0.58 + (drift ? -10 : 14),
                        y: geo.size.height * 0.62
                    )

                Circle()
                    .fill(AppTheme.bloomMint.opacity(0.22))
                    .frame(width: geo.size.width * 0.34)
                    .blur(radius: 40)
                    .offset(
                        x: geo.size.width * 0.7,
                        y: geo.size.height * 0.08 + (drift ? 16 : 0)
                    )

                // Soft floor vignette for depth
                LinearGradient(
                    colors: [Color.clear, Color.white.opacity(0.18)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
