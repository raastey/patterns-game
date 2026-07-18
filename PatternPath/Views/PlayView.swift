import SwiftUI

struct PlayView: View {
    @Environment(ProgressStore.self) private var progress
    @State private var session: GameSession
    let onExit: () -> Void
    let onNextLevel: (Int) -> Void
    let onMap: () -> Void

    @State private var appear = false

    init(level: GameLevel, onExit: @escaping () -> Void, onNextLevel: @escaping (Int) -> Void, onMap: @escaping () -> Void) {
        _session = State(initialValue: GameSession(level: level))
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        self.onMap = onMap
    }

    var body: some View {
        ZStack {
            SkyBackground()

            AdaptiveReader { layout in
                Group {
                    if layout.isLandscape {
                        landscapeBody(layout)
                    } else {
                        portraitBody(layout)
                    }
                }
                .padding(.horizontal, layout.horizontalPadding)
                .padding(.vertical, layout.isShortLandscape ? 8 : 12)
            }

            if session.phase == .celebrating {
                CelebrationView(
                    level: session.level,
                    stars: session.starsEarned(),
                    hasNext: session.level.id < LevelCatalog.totalCount,
                    onNext: { onNextLevel(session.level.id + 1) },
                    onMap: onMap,
                    onReplay: {
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
                progress.recordClear(
                    levelID: session.level.id,
                    stars: session.level.starsToEarn,
                    mistakes: session.mistakes
                )
                if progress.highestUnlocked > previousUnlocked {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        HapticsPlayer.shared.unlock()
                    }
                }
            }
        }
    }

    // MARK: - Portrait

    private func portraitBody(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: 0) {
            topBar(layout)
            Spacer(minLength: layout.isCompactWidth ? 8 : 14)
            headerBlock(layout, compact: false)
            Spacer(minLength: layout.isCompactWidth ? 14 : 20)
            ribbonBlock(layout)
            streakLabel
            Spacer(minLength: layout.isCompactWidth ? 14 : 22)
            paletteBlock(layout)
            Spacer(minLength: layout.isCompactWidth ? 16 : 24)
        }
    }

    // MARK: - Landscape

    private func landscapeBody(_ layout: AdaptiveLayout) -> some View {
        VStack(spacing: layout.isShortLandscape ? 8 : 12) {
            topBar(layout)

            HStack(alignment: .center, spacing: layout.isShortLandscape ? 16 : 28) {
                VStack(alignment: .leading, spacing: 10) {
                    headerBlock(layout, compact: true)
                    streakLabel
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: layout.isShortLandscape ? 180 : 240, alignment: .leading)

                VStack(spacing: layout.isShortLandscape ? 10 : 16) {
                    ribbonBlock(layout)
                    paletteBlock(layout)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
    }

    // MARK: - Pieces

    private func topBar(_ layout: AdaptiveLayout) -> some View {
        HStack(spacing: 8) {
            ToolbarChip(
                title: layout.isShortLandscape || layout.isCompactWidth ? "Map" : "Levels",
                systemImage: "square.grid.2x2.fill"
            ) {
                onExit()
            }

            Spacer(minLength: 4)

            StatusChip(text: "Level \(session.level.id)")

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                MuteButton()
                HapticsButton()
                if !layout.isShortLandscape {
                    StatusChip(text: session.progressText)
                        .accessibilityLabel("Filled \(session.nextAnswerIndex) of \(session.level.answers.count)")
                }
            }
        }
    }

    private func headerBlock(_ layout: AdaptiveLayout, compact: Bool) -> some View {
        VStack(alignment: compact ? .leading : .center, spacing: compact ? 6 : 10) {
            Text(session.level.title)
                .font(.display(layout.playTitleSize, weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(compact ? .leading : .center)
                .lineLimit(compact ? 2 : 2)
                .minimumScaleFactor(0.8)

            FocusBadge(focus: session.level.focus)

            if !layout.isShortLandscape {
                Text(session.level.subtitle)
                    .font(.bodyRounded(compact ? 15 : (layout.isCompactWidth ? 16 : 19), weight: .medium))
                    .foregroundStyle(AppTheme.inkSoft)
                    .multilineTextAlignment(compact ? .leading : .center)
            }

            if layout.isShortLandscape {
                Text(session.progressText)
                    .font(.bodyRounded(14, weight: .semibold))
                    .foregroundStyle(AppTheme.inkSoft)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: compact ? .leading : .center)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 12)
    }

    private func ribbonBlock(_ layout: AdaptiveLayout) -> some View {
        PatternRibbon(
            slots: session.slots,
            columns: session.level.columns,
            activeBlankIndex: activeBlankIndex,
            shakeBlankIndex: session.shakeBlankIndex,
            lastPlacedIndex: session.lastPlacedIndex,
            tokenSize: layout.ribbonTokenSize(
                slotCount: session.slots.count,
                columns: session.level.columns
            )
        )
        .scaleEffect(session.popToken > 0 ? 1.02 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.55), value: session.popToken)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 14)
    }

    private func paletteBlock(_ layout: AdaptiveLayout) -> some View {
        ChoicePalette(
            choices: session.choices,
            focus: session.level.focus,
            wrongChoiceID: session.wrongChoiceID,
            tokenSize: layout.choiceTokenSize(choiceCount: session.choices.count),
            compact: layout.isShortLandscape
        ) { token in
            session.place(token)
        }
        .frame(maxWidth: layout.isLandscape ? .infinity : 720)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 18)
    }

    @ViewBuilder
    private var streakLabel: some View {
        if session.streak >= 2, session.phase == .playing {
            Text("\(session.streak) in a row!")
                .font(.bodyRounded(15, weight: .bold))
                .foregroundStyle(AppTheme.accentDeep)
                .transition(.scale.combined(with: .opacity))
        }
    }

    private var activeBlankIndex: Int? {
        session.slots.firstIndex(where: \.isBlank)
    }
}
