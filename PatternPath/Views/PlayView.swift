import SwiftUI

struct PlayView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var session: GameSession
    let onExit: () -> Void
    let onNextLevel: (Int) -> Void
    let onMap: () -> Void

    @State private var appear = false

    private var isCompact: Bool { sizeClass == .compact }

    init(level: GameLevel, onExit: @escaping () -> Void, onNextLevel: @escaping (Int) -> Void, onMap: @escaping () -> Void) {
        _session = State(initialValue: GameSession(level: level))
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        self.onMap = onMap
    }

    var body: some View {
        ZStack {
            SkyBackground()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, isCompact ? 16 : 28)
                    .padding(.top, 12)

                Spacer(minLength: isCompact ? 8 : 16)

                VStack(spacing: 10) {
                    Text(session.level.title)
                        .font(.display(isCompact ? 28 : 36, weight: .bold))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.center)

                    FocusBadge(focus: session.level.focus)

                    Text(session.level.subtitle)
                        .font(.bodyRounded(isCompact ? 16 : 19, weight: .medium))
                        .foregroundStyle(AppTheme.inkSoft)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)

                Spacer(minLength: isCompact ? 16 : 24)

                PatternRibbon(
                    slots: session.slots,
                    activeBlankIndex: activeBlankIndex,
                    shakeBlankIndex: session.shakeBlankIndex,
                    lastPlacedIndex: session.lastPlacedIndex,
                    tokenSize: ribbonTokenSize
                )
                .padding(.horizontal, isCompact ? 12 : 20)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 18)

                Spacer(minLength: isCompact ? 16 : 28)

                ChoicePalette(
                    choices: session.choices,
                    focus: session.level.focus,
                    wrongChoiceID: session.wrongChoiceID,
                    tokenSize: choiceTokenSize
                ) { token in
                    session.place(token)
                }
                .padding(.horizontal, isCompact ? 16 : 28)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 22)

                Spacer(minLength: isCompact ? 20 : 32)
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

    private var topBar: some View {
        HStack(spacing: 10) {
            ToolbarChip(title: isCompact ? "Map" : "Levels", systemImage: "square.grid.2x2.fill") {
                onExit()
            }

            Spacer(minLength: 8)

            StatusChip(text: "Level \(session.level.id)")

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                MuteButton()
                HapticsButton()
                StatusChip(text: session.progressText)
                    .accessibilityLabel("Filled \(session.nextAnswerIndex) of \(session.level.answers.count)")
            }
        }
    }

    private var activeBlankIndex: Int? {
        session.slots.firstIndex(where: \.isBlank)
    }

    private var ribbonTokenSize: CGFloat {
        let count = session.slots.count
        let base: CGFloat = isCompact ? 58 : 82
        if count >= 9 { return base - 16 }
        if count >= 7 { return base - 8 }
        return base
    }

    private var choiceTokenSize: CGFloat {
        let base: CGFloat = isCompact ? 64 : 86
        return session.choices.count >= 5 ? base - 12 : base
    }
}
