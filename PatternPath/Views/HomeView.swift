import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(\.horizontalSizeClass) private var sizeClass
    let onPlay: () -> Void
    let onLevels: () -> Void

    @State private var bob = false
    @State private var appear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isCompact: Bool { sizeClass == .compact }

    var body: some View {
        ZStack {
            SkyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: isCompact ? 28 : 36) {
                    HStack(spacing: 8) {
                        Spacer()
                        MuteButton()
                        HapticsButton()
                    }
                    .padding(.top, 8)

                    brandBlock
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 28)

                    heroPath
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.94)

                    VStack(spacing: 14) {
                        PrimaryCTA(
                            title: progress.highestUnlocked == 1 && progress.totalStars == 0
                                ? "Start Playing"
                                : "Keep Going",
                            systemImage: "play.fill"
                        ) {
                            SoundPlayer.shared.playTap()
                            onPlay()
                        }

                        SecondaryCTA(title: "All Levels", systemImage: "square.grid.2x2.fill") {
                            SoundPlayer.shared.playTap()
                            onLevels()
                        }

                        StatusChip(
                            text: "\(progress.totalStars) stars",
                            systemImage: "star.fill",
                            tint: AppTheme.star
                        )
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: isCompact ? .infinity : 420)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 18)
                }
                .padding(.horizontal, isCompact ? 24 : 48)
                .padding(.bottom, 40)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
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

    private var brandBlock: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                TokenView(token: PatternToken(shape: .circle, hue: .coral), size: isCompact ? 40 : 48)
                TokenView(token: PatternToken(shape: .square, hue: .teal), size: isCompact ? 40 : 48)
                TokenView(token: PatternToken(shape: .star, hue: .sunflower), size: isCompact ? 40 : 48)
            }
            .offset(y: bob ? -5 : 4)

            Text("Pattern Path")
                .font(.display(isCompact ? 44 : 62, weight: .heavy))
                .foregroundStyle(AppTheme.ink)
                .tracking(-0.5)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("Complete the beads.\nOne thing to watch at a time.")
                .font(.bodyRounded(isCompact ? 18 : 21, weight: .medium))
                .foregroundStyle(AppTheme.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    private var heroPath: some View {
        HStack(spacing: isCompact ? 12 : 16) {
            TokenView(token: PatternToken(shape: .circle, hue: .coral), size: isCompact ? 52 : 68)
            TokenView(token: PatternToken(shape: .circle, hue: .teal), size: isCompact ? 52 : 68)
            TokenView(token: PatternToken(shape: .circle, hue: .coral), size: isCompact ? 52 : 68)
            BlankSlotView(size: isCompact ? 52 : 68, isActive: true)
            TokenView(token: PatternToken(shape: .circle, hue: .teal), size: isCompact ? 52 : 68)
                .opacity(0.22)
        }
        .padding(.horizontal, isCompact ? 22 : 34)
        .padding(.vertical, isCompact ? 18 : 24)
        .background {
            Capsule(style: .continuous)
                .fill(AppTheme.trayGradient)
                .overlay {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                }
                .shadow(color: AppTheme.trayDeep.opacity(0.3), radius: 20, y: 12)
        }
    }
}
