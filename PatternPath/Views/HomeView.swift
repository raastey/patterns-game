import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    let onPlay: () -> Void
    let onLevels: () -> Void
    let onStickers: () -> Void

    @State private var bob = false
    @State private var appear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var theme: WorldTheme {
        WorldTheme.forLevelID(max(1, progress.highestUnlocked))
    }

    var body: some View {
        ZStack {
            SkyBackground(theme: theme)

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
        VStack(spacing: layout.isCompactWidth ? 22 : 28) {
            toolbar
            brandBlock(layout)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)
            garageProgress(layout)
                .opacity(appear ? 1 : 0)
            heroPath(layout)
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.94)
            StickerStripView(compact: layout.isCompactWidth, onOpen: onStickers)
                .opacity(appear ? 1 : 0)
            actions(layout)
                .frame(maxWidth: layout.isCompactWidth ? .infinity : 420)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 16)
        }
    }

    private func landscapeContent(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: layout.isShortLandscape ? 10 : 16) {
            toolbar
            HStack(alignment: .center, spacing: layout.isShortLandscape ? 18 : 32) {
                VStack(alignment: .leading, spacing: layout.isShortLandscape ? 10 : 16) {
                    brandBlock(layout)
                    garageProgress(layout)
                    StickerStripView(compact: true, onOpen: onStickers)
                }
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
            HStack(spacing: 8) {
                TokenView(token: PatternToken(toy: .modelT, hue: .coral), size: layout.isShortLandscape ? 34 : (layout.isCompactWidth ? 40 : 48))
                TokenView(token: PatternToken(toy: .bus, hue: .sunflower), size: layout.isShortLandscape ? 34 : (layout.isCompactWidth ? 40 : 48))
                TokenView(token: PatternToken(toy: .fireTruck, hue: .periwinkle), size: layout.isShortLandscape ? 34 : (layout.isCompactWidth ? 40 : 48))
                TokenView(token: PatternToken(toy: .jeep, hue: .mint), size: layout.isShortLandscape ? 34 : (layout.isCompactWidth ? 40 : 48))
            }
            .offset(y: bob ? -4 : 3)

            Text("Pattern Path")
                .font(.display(layout.homeTitleSize, weight: .heavy))
                .foregroundStyle(AppTheme.ink)
                .tracking(-0.5)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(layout.isShortLandscape
                 ? "Tiny garage missions. One thing at a time."
                 : "Park the toys. Fill the garage.\nOne thing to watch at a time.")
                .font(.bodyRounded(layout.isShortLandscape ? 16 : (layout.isCompactWidth ? 18 : 21), weight: .medium))
                .foregroundStyle(AppTheme.inkSoft)
                .multilineTextAlignment(layout.isLandscape ? .leading : .center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: layout.isLandscape ? .leading : .center)
    }

    private func garageProgress(_ layout: AdaptiveLayout) -> some View {
        VStack(alignment: layout.isLandscape ? .leading : .center, spacing: 8) {
            Text("Your garage")
                .font(.bodyRounded(layout.isShortLandscape ? 13 : 15, weight: .bold))
                .foregroundStyle(AppTheme.ink)
            GarageBaysView(compact: layout.isShortLandscape || layout.isCompactWidth)
        }
        .padding(layout.isShortLandscape ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: layout.isLandscape ? .leading : .center)
        .glassSurface(cornerRadius: 22, intense: false)
    }

    private func heroPath(_ layout: AdaptiveLayout) -> some View {
        let bead: CGFloat = layout.isShortLandscape ? 40 : (layout.isCompactWidth ? 48 : 60)
        let gap = bead * 0.16
        return VStack(spacing: gap) {
            HStack(spacing: gap) {
                TokenView(token: PatternToken(toy: .modelT, hue: .coral), size: bead)
                TokenView(token: PatternToken(toy: .topolino, hue: .sunflower), size: bead)
                TokenView(token: PatternToken(toy: .bus, hue: .periwinkle), size: bead)
            }
            HStack(spacing: gap) {
                TokenView(token: PatternToken(toy: .jeep, hue: .mint), size: bead)
                BlankSlotView(size: bead, isActive: true)
                TokenView(token: PatternToken(toy: .fireTruck, hue: .apricot), size: bead)
                    .opacity(0.35)
            }
        }
        .padding(.horizontal, bead * 0.42)
        .padding(.vertical, bead * 0.36)
        .background {
            RoundedRectangle(cornerRadius: bead * 0.45, style: .continuous)
                .fill(theme.trayGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: bead * 0.45, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [theme.lamp.opacity(0.22), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: bead * 0.45, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                }
                .shadow(color: theme.trayDeep.opacity(0.35), radius: 16, y: 10)
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
                text: "\(progress.totalStars) stars · \(progress.clearedLevelCount)/50 parked",
                systemImage: "star.fill",
                tint: AppTheme.star
            )
        }
    }
}
