import SwiftUI

struct CelebrationView: View {
    let level: GameLevel
    let stars: Int
    let hasNext: Bool
    let onNext: () -> Void
    let onMap: () -> Void
    let onReplay: () -> Void

    @State private var showStars = false
    @State private var burst = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isShort: Bool { verticalSizeClass == .compact }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.12))
                .ignoresSafeArea()

            if !reduceMotion {
                confetti
            }

            ScrollViewIfNeeded(enabled: isShort) {
                VStack(spacing: isShort ? 12 : 20) {
                    Image(systemName: level.id == LevelCatalog.totalCount ? "crown.fill" : "sparkles")
                        .font(.system(size: isShort ? 28 : 36, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                        .symbolEffect(.bounce, value: burst)

                    Text(level.id == LevelCatalog.totalCount ? "Every path complete" : "Beautiful")
                        .font(.display(isShort ? 26 : 34, weight: .heavy))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)

                    Text(level.title)
                        .font(.bodyRounded(isShort ? 15 : 18, weight: .semibold))
                        .foregroundStyle(AppTheme.inkSoft)

                    HStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < stars ? "star.fill" : "star")
                                .font(.system(size: isShort ? 30 : 38, weight: .bold))
                                .foregroundStyle(index < stars ? AppTheme.star : AppTheme.inkFaint.opacity(0.25))
                                .scaleEffect(showStars && index < stars ? 1.0 : 0.35)
                                .opacity(showStars ? 1 : 0)
                                .animation(
                                    Motion.bouncy.delay(Double(index) * 0.14),
                                    value: showStars
                                )
                                .onChange(of: showStars) { _, visible in
                                    guard visible, index < stars else { return }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.14) {
                                        HapticsPlayer.shared.starPop(index: index)
                                    }
                                }
                        }
                    }
                    .padding(.vertical, isShort ? 2 : 6)

                    VStack(spacing: 10) {
                        if hasNext {
                            PrimaryCTA(title: "Next Level", systemImage: "arrow.right") {
                                SoundPlayer.shared.playTap()
                                HapticsPlayer.shared.unlock()
                                onNext()
                            }
                        }

                        HStack(spacing: 10) {
                            SecondaryCTA(title: "Again", systemImage: "arrow.counterclockwise") {
                                onReplay()
                            }
                            SecondaryCTA(title: "Levels", systemImage: "square.grid.2x2") {
                                onMap()
                            }
                        }
                    }
                }
                .padding(isShort ? 20 : 32)
                .frame(maxWidth: 440)
                .glassSurface(cornerRadius: isShort ? 28 : 40, intense: true)
                .padding(isShort ? 12 : 24)
            }
            .scaleEffect(burst ? 1 : 0.9)
            .opacity(burst ? 1 : 0)
        }
        .onAppear {
            withAnimation(Motion.softSpring) { burst = true }
            showStars = true
        }
        .accessibilityAddTraits(.isModal)
    }

    private var confetti: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let colors: [Color] = [
                    AppTheme.coral, AppTheme.teal, AppTheme.sunflower,
                    AppTheme.periwinkle, AppTheme.mint, AppTheme.apricot
                ]
                for i in 0..<24 {
                    let seed = Double(i) * 17.13
                    let x = (sin(seed) * 0.5 + 0.5) * size.width
                    let fall = (t * (36 + Double(i % 7) * 7) + seed * 20)
                        .truncatingRemainder(dividingBy: size.height + 40)
                    let y = fall - 20
                    let w: CGFloat = i.isMultiple(of: 3) ? 8 : 11
                    let rect = CGRect(x: x, y: y, width: w, height: w * 1.3)
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 3),
                        with: .color(colors[i % colors.count].opacity(0.75))
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
