import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    let onPlay: () -> Void
    let onLevels: () -> Void

    @State private var bob = false
    @State private var appear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            SkyBackground()

            AdaptiveReader { layout in
                ScrollView(showsIndicators: false) {
                    Group {
                        if layout.isLandscape {
                            landscapeContent(layout)
                        } else {
                            portraitContent(layout)
                        }
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.vertical, layout.isShortLandscape ? 12 : 20)
                    .frame(maxWidth: 980)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            HapticsPlayer.shared.prepare()
            HapticsPlayer.shared.welcome()
            withAnimation(Motion.softSpring) { appear = true }
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
    }

    private func portraitContent(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: layout.isCompactWidth ? 26 : 34) {
            toolbar
            brandBlock(layout)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)
            heroPath(layout)
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.94)
            actions(layout)
                .frame(maxWidth: layout.isCompactWidth ? .infinity : 420)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 16)
        }
    }

    private func landscapeContent(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: layout.isShortLandscape ? 12 : 20) {
            toolbar
            HStack(alignment: .center, spacing: layout.isShortLandscape ? 20 : 36) {
                brandBlock(layout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(appear ? 1 : 0)

                VStack(spacing: layout.isShortLandscape ? 12 : 18) {
                    heroPath(layout)
                    actions(layout)
                }
                .frame(maxWidth: layout.isShortLandscape ? 340 : 420)
                .opacity(appear ? 1 : 0)
            }
            .frame(minHeight: layout.size.height - 80)
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Spacer()
            MuteButton()
            HapticsButton()
        }
    }

    private func brandBlock(_ layout: AdaptiveLayout) -> some View {
        VStack(alignment: layout.isLandscape ? .leading : .center, spacing: 12) {
            HStack(spacing: 10) {
                TokenView(token: PatternToken(toy: .fireTruck, hue: .coral), size: layout.isShortLandscape ? 36 : (layout.isCompactWidth ? 42 : 50))
                TokenView(token: PatternToken(toy: .policeCar, hue: .periwinkle), size: layout.isShortLandscape ? 36 : (layout.isCompactWidth ? 42 : 50))
                TokenView(token: PatternToken(toy: .robot, hue: .mint), size: layout.isShortLandscape ? 36 : (layout.isCompactWidth ? 42 : 50))
            }
            .offset(y: bob ? -4 : 3)

            Text("Pattern Path")
                .font(.display(layout.homeTitleSize, weight: .heavy))
                .foregroundStyle(AppTheme.ink)
                .tracking(-0.5)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(layout.isShortLandscape
                 ? "Park the toys. One thing at a time."
                 : "Cars, trucks, robots.\nOne thing to watch at a time.")
                .font(.bodyRounded(layout.isShortLandscape ? 16 : (layout.isCompactWidth ? 18 : 21), weight: .medium))
                .foregroundStyle(AppTheme.inkSoft)
                .multilineTextAlignment(layout.isLandscape ? .leading : .center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: layout.isLandscape ? .leading : .center)
    }

    private func heroPath(_ layout: AdaptiveLayout) -> some View {
        let bead: CGFloat = layout.isShortLandscape ? 40 : (layout.isCompactWidth ? 48 : 60)
        let gap = bead * 0.16
        return VStack(spacing: gap) {
            HStack(spacing: gap) {
                TokenView(token: PatternToken(toy: .fireTruck, hue: .coral), size: bead)
                TokenView(token: PatternToken(toy: .policeCar, hue: .periwinkle), size: bead)
                TokenView(token: PatternToken(toy: .raceCar, hue: .sunflower), size: bead)
            }
            HStack(spacing: gap) {
                TokenView(token: PatternToken(toy: .robot, hue: .mint), size: bead)
                BlankSlotView(size: bead, isActive: true)
                TokenView(token: PatternToken(toy: .carCarrier, hue: .apricot), size: bead)
                    .opacity(0.35)
            }
        }
        .padding(.horizontal, bead * 0.42)
        .padding(.vertical, bead * 0.36)
        .background {
            RoundedRectangle(cornerRadius: bead * 0.45, style: .continuous)
                .fill(AppTheme.trayGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: bead * 0.45, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: bead * 0.45, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                }
                .shadow(color: AppTheme.trayDeep.opacity(0.3), radius: 16, y: 10)
        }
    }

    private func actions(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: layout.isShortLandscape ? 10 : 14) {
            PrimaryCTA(
                title: progress.highestUnlocked == 1 && progress.totalStars == 0
                    ? "Start Playing"
                    : "Keep Going",
                systemImage: "play.fill"
            ) {
                SoundPlayer.shared.playTap()
                HapticsPlayer.shared.warmUp()
                onPlay()
            }

            SecondaryCTA(title: "All Levels", systemImage: "square.grid.2x2.fill") {
                SoundPlayer.shared.playTap()
                onLevels()
            }

            if !layout.isShortLandscape {
                Button {
                    HapticsPlayer.shared.warmUp()
                    HapticsPlayer.shared.testBurst()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 16, weight: .bold))
                        Text("Feel That?")
                            .font(.bodyRounded(17, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.accentDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        Capsule(style: .continuous)
                            .fill(AppTheme.accent.opacity(0.14))
                            .overlay {
                                Capsule(style: .continuous)
                                    .strokeBorder(AppTheme.accent.opacity(0.3), lineWidth: 1)
                            }
                    }
                }
                .buttonStyle(PremiumPressStyle())
            }

            StatusChip(
                text: "\(progress.totalStars) stars · 50 levels",
                systemImage: "star.fill",
                tint: AppTheme.star
            )
        }
    }
}
