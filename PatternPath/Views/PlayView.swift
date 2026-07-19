import SwiftUI

struct PlayView: View {
    @Environment(ProgressStore.self) private var progress
    @State private var session: GameSession
    @State private var newSticker: GarageSticker?
    let onExit: () -> Void
    let onNextLevel: (Int) -> Void
    let onMap: () -> Void

    @State private var appear = false
    @State private var shelfWidth: CGFloat = 0

    init(level: GameLevel, onExit: @escaping () -> Void, onNextLevel: @escaping (Int) -> Void, onMap: @escaping () -> Void) {
        _session = State(initialValue: GameSession(level: level))
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        self.onMap = onMap
    }

    private var theme: WorldTheme { session.level.theme }

    var body: some View {
        ZStack {
            SkyBackground(theme: theme)

            AdaptiveReader { layout in
                playBody(layout)
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.top, layout.isShortLandscape ? 6 : 10)
                    .padding(.bottom, layout.isShortLandscape ? 6 : 10)
            }

            if session.phase == .celebrating {
                CelebrationView(
                    level: session.level,
                    stars: session.starsEarned(),
                    hasNext: session.level.id < LevelCatalog.totalCount,
                    newSticker: newSticker,
                    worldFill: progress.worldFill(worldID: session.level.world),
                    onNext: { onNextLevel(session.level.id + 1) },
                    onMap: onMap,
                    onReplay: {
                        newSticker = nil
                        session = GameSession(level: session.level)
                        appear = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(Motion.softSpring) { appear = true }
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .onAppear {
            HapticsPlayer.shared.prepare()
            SoundPlayer.shared.playLevelStart()
            HapticsPlayer.shared.levelStart()
            withAnimation(Motion.softSpring) { appear = true }
        }
        .onChange(of: session.phase) { _, phase in
            if phase == .celebrating {
                let previousUnlocked = progress.highestUnlocked
                newSticker = progress.recordClear(
                    levelID: session.level.id,
                    stars: session.level.starsToEarn,
                    mistakes: session.mistakes
                )
                if progress.highestUnlocked > previousUnlocked || newSticker != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        HapticsPlayer.shared.unlock()
                    }
                }
            }
        }
    }

    // MARK: - Layout

    private func playBody(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: layout.isShortLandscape ? 8 : 12) {
            topBar(layout)
            titleLine(layout)
            missionChip(layout)

            PatternRibbon(
                slots: session.slots,
                columns: session.level.columns,
                theme: theme,
                activeBlankIndex: activeBlankIndex,
                shakeBlankIndex: session.shakeBlankIndex,
                lastPlacedIndex: session.lastPlacedIndex,
                tokenSize: nil
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(session.popToken > 0 ? 1.015 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.55), value: session.popToken)
            .opacity(appear ? 1 : 0)

            streakLabel

            ChoicePalette(
                choices: session.choices,
                focus: session.level.focus,
                wrongChoiceID: session.wrongChoiceID,
                tokenSize: layout.choiceTokenSize(
                    choiceCount: session.choices.count,
                    shelfWidth: shelfWidth > 0 ? shelfWidth : nil
                ),
                compact: layout.isShortLandscape
            ) { token in
                session.place(token)
            }
            .background {
                GeometryReader { geo in
                    Color.clear.preference(key: ShelfWidthKey.self, value: geo.size.width)
                }
            }
            .onPreferenceChange(ShelfWidthKey.self) { shelfWidth = $0 }
            .opacity(appear ? 1 : 0)
        }
    }

    // MARK: - Chrome

    private func topBar(_ layout: AdaptiveLayout) -> some View {
        HStack(spacing: 8) {
            ToolbarChip(
                title: layout.isCompactWidth || layout.isShortLandscape ? "Map" : "Levels",
                systemImage: "square.grid.2x2.fill"
            ) {
                onExit()
            }

            Spacer(minLength: 4)

            StatusChip(text: "\(theme.title) · \(session.level.id)")

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                MuteButton()
                HapticsButton()
                StatusChip(text: session.progressText)
                    .accessibilityLabel("Filled \(session.nextAnswerIndex) of \(session.level.answers.count)")
            }
        }
    }

    private func titleLine(_ layout: AdaptiveLayout) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(session.level.title)
                .font(.display(layout.playTitleSize, weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            FocusBadge(focus: session.level.focus)

            Spacer(minLength: 0)
        }
        .opacity(appear ? 1 : 0)
    }

    private func missionChip(_ layout: AdaptiveLayout) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "flag.fill")
                .font(.system(size: layout.isShortLandscape ? 11 : 12, weight: .bold))
                .foregroundStyle(theme.lamp)
            Text(session.level.missionLine)
                .font(.bodyRounded(layout.isShortLandscape ? 13 : 15, weight: .semibold))
                .foregroundStyle(AppTheme.inkSoft)
                .lineLimit(layout.isShortLandscape ? 1 : 2)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, layout.isShortLandscape ? 7 : 9)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.55))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                }
        }
        .opacity(appear ? 1 : 0)
    }

    @ViewBuilder
    private var streakLabel: some View {
        if session.streak >= 2, session.phase == .playing {
            Text("\(session.streak) in a row!")
                .font(.bodyRounded(16, weight: .bold))
                .foregroundStyle(AppTheme.accentDeep)
                .frame(maxWidth: .infinity)
                .transition(.scale.combined(with: .opacity))
        }
    }

    private var activeBlankIndex: Int? {
        session.slots.firstIndex(where: \.isBlank)
    }
}

private struct ShelfWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
