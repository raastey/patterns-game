import SwiftUI

struct CelebrationView: View {
    let level: GameLevel
    let stars: Int
    let hasNext: Bool
    var newSticker: GarageSticker? = nil
    var completedWorldID: Int? = nil
    var worldFill: Double = 0
    let onNext: () -> Void
    let onMap: () -> Void
    let onReplay: () -> Void

    @State private var showStars = false
    @State private var burst = false
    @State private var lightsOn = false
    @State private var carParked = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isShort: Bool { verticalSizeClass == .compact }
    private var theme: WorldTheme { level.theme }
    private var wantsThreeStars: Bool { stars < 3 }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(theme.trayDeep.opacity(0.18))
                .ignoresSafeArea()

            if !reduceMotion {
                softConfetti
            }

            ScrollViewIfNeeded(enabled: isShort) {
                VStack(spacing: isShort ? 10 : 16) {
                    garageBayScene
                        .padding(.bottom, isShort ? 2 : 4)

                    if let completedWorldID {
                        worldCompleteBanner(WorldTheme.forWorld(completedWorldID))
                    }

                    Text(level.winLine)
                        .font(.display(isShort ? 24 : 30, weight: .heavy))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)

                    Text(level.title)
                        .font(.bodyRounded(isShort ? 14 : 16, weight: .semibold))
                        .foregroundStyle(AppTheme.inkSoft)

                    if let newSticker {
                        stickerUnlockBanner(newSticker)
                    }

                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < stars ? "star.fill" : "star")
                                .font(.system(size: isShort ? 28 : 36, weight: .bold))
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
                    .padding(.vertical, isShort ? 2 : 4)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(stars) of 3 stars")

                    if wantsThreeStars {
                        Text("Almost! Try again for 3 stars.")
                            .font(.bodyRounded(isShort ? 14 : 16, weight: .semibold))
                            .foregroundStyle(AppTheme.accentDeep)
                            .multilineTextAlignment(.center)
                    }

                    worldFillChip

                    VStack(spacing: 10) {
                        if wantsThreeStars {
                            PrimaryCTA(title: "Try for 3 Stars", systemImage: "star.fill") {
                                SoundPlayer.shared.playTap()
                                onReplay()
                            }
                            if hasNext {
                                SecondaryCTA(title: "Next Level", systemImage: "arrow.right") {
                                    SoundPlayer.shared.playTap()
                                    HapticsPlayer.shared.unlock()
                                    onNext()
                                }
                            }
                        } else if hasNext {
                            PrimaryCTA(title: "Next Level", systemImage: "arrow.right") {
                                SoundPlayer.shared.playTap()
                                HapticsPlayer.shared.unlock()
                                onNext()
                            }
                        }

                        HStack(spacing: 10) {
                            if !wantsThreeStars {
                                SecondaryCTA(title: "Again", systemImage: "arrow.counterclockwise") {
                                    onReplay()
                                }
                            }
                            SecondaryCTA(title: "Levels", systemImage: "square.grid.2x2") {
                                onMap()
                            }
                        }
                    }
                }
                .padding(isShort ? 18 : 28)
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
            runBayAnimation()
        }
        .accessibilityAddTraits(.isModal)
    }

    private var garageBayScene: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isShort ? 18 : 22, style: .continuous)
                .fill(theme.trayGradient)
                .frame(height: isShort ? 88 : 108)
                .overlay {
                    RoundedRectangle(cornerRadius: isShort ? 18 : 22, style: .continuous)
                        .strokeBorder(theme.laneLine.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .padding(10)
                }
                .overlay(alignment: .top) {
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { _ in
                            Capsule()
                                .fill(theme.lamp.opacity(lightsOn ? 0.85 : 0.18))
                                .frame(width: isShort ? 22 : 28, height: isShort ? 5 : 6)
                                .shadow(color: theme.lamp.opacity(lightsOn ? 0.55 : 0), radius: lightsOn ? 8 : 0)
                        }
                    }
                    .padding(.top, 10)
                }

            TokenView(token: level.mascot, size: isShort ? 44 : 54)
                .offset(x: carParked ? 0 : (reduceMotion ? 0 : -120))
                .opacity(carParked || reduceMotion ? 1 : 0.15)
                .animation(Motion.softSpring, value: carParked)
        }
        .padding(.horizontal, 4)
        .accessibilityHidden(true)
    }

    private var worldFillChip: some View {
        HStack(spacing: 8) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(theme.lamp)
            Text("\(level.worldTitle) · \(Int((worldFill * 10).rounded()))/10 bays")
                .font(.captionRounded(12))
                .foregroundStyle(AppTheme.inkSoft)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background {
            Capsule().fill(AppTheme.ink.opacity(0.06))
        }
    }

    private func worldCompleteBanner(_ world: WorldTheme) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(world.lamp)
            Text("\(world.title) complete!")
                .font(.bodyRounded(isShort ? 15 : 17, weight: .bold))
                .foregroundStyle(AppTheme.ink)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(world.lamp.opacity(0.16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(world.lamp.opacity(0.35), lineWidth: 1)
                }
        }
    }

    private func stickerUnlockBanner(_ sticker: GarageSticker) -> some View {
        HStack(spacing: 12) {
            TokenView(token: sticker.token, size: isShort ? 36 : 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("New sticker!")
                    .font(.captionRounded(11))
                    .foregroundStyle(AppTheme.accentDeep)
                Text(sticker.label)
                    .font(.bodyRounded(isShort ? 15 : 17, weight: .bold))
                    .foregroundStyle(AppTheme.ink)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.accent.opacity(0.14))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AppTheme.accent.opacity(0.28), lineWidth: 1)
                }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func runBayAnimation() {
        if reduceMotion {
            lightsOn = true
            carParked = true
            return
        }
        lightsOn = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.22)) { lightsOn = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            withAnimation(.easeInOut(duration: 0.18)) { lightsOn = false }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            withAnimation(.easeInOut(duration: 0.28)) { lightsOn = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(Motion.softSpring) { carParked = true }
        }
    }

    private var softConfetti: some View {
        TimelineView(.animation(minimumInterval: 1 / 24)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let colors: [Color] = [
                    theme.lamp.opacity(0.7),
                    AppTheme.sunflower.opacity(0.65),
                    AppTheme.mint.opacity(0.55),
                    AppTheme.periwinkle.opacity(0.5),
                    Color.white.opacity(0.55)
                ]
                for i in 0..<14 {
                    let seed = Double(i) * 19.7
                    let x = (sin(seed + 0.4) * 0.5 + 0.5) * size.width
                    let fall = (t * (18 + Double(i % 5) * 4) + seed * 14)
                        .truncatingRemainder(dividingBy: size.height + 30)
                    let y = fall - 16
                    let w: CGFloat = i.isMultiple(of: 2) ? 6 : 9
                    let rect = CGRect(x: x, y: y, width: w, height: w * 0.7)
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 2),
                        with: .color(colors[i % colors.count])
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
