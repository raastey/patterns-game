import SwiftUI

struct LevelMapView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(\.horizontalSizeClass) private var sizeClass
    let onSelect: (Int) -> Void
    let onBack: () -> Void

    private var columns: [GridItem] {
        let min: CGFloat = sizeClass == .compact ? 108 : 148
        let max: CGFloat = sizeClass == .compact ? 140 : 180
        return [GridItem(.adaptive(minimum: min, maximum: max), spacing: 16)]
    }

    var body: some View {
        ZStack {
            SkyBackground()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, sizeClass == .compact ? 16 : 28)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 22) {
                        ForEach(worlds, id: \.id) { world in
                            worldSection(world)
                        }
                    }
                    .padding(.horizontal, sizeClass == .compact ? 16 : 28)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            ToolbarChip(title: "Home", systemImage: "chevron.left", action: onBack)

            Spacer()

            Text("Levels")
                .font(.display(sizeClass == .compact ? 26 : 34, weight: .bold))
                .foregroundStyle(AppTheme.ink)

            Spacer()

            HStack(spacing: 8) {
                StatusChip(
                    text: "\(progress.totalStars)",
                    systemImage: "star.fill",
                    tint: AppTheme.star
                )
                MuteButton()
                HapticsButton()
            }
        }
    }

    private func worldSection(_ world: WorldGroup) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text(world.title)
                    .font(.display(22, weight: .bold))
                    .foregroundStyle(AppTheme.ink)

                Text("\(world.levels.first?.id ?? 0)–\(world.levels.last?.id ?? 0)")
                    .font(.captionRounded(13))
                    .foregroundStyle(AppTheme.inkFaint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        Capsule().fill(AppTheme.ink.opacity(0.06))
                    }
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(world.levels) { level in
                    LevelCard(
                        level: level,
                        stars: progress.stars(for: level.id),
                        unlocked: progress.isUnlocked(level.id)
                    ) {
                        SoundPlayer.shared.playTap()
                        HapticsPlayer.shared.navigate()
                        onSelect(level.id)
                    }
                }
            }
        }
        .padding(sizeClass == .compact ? 16 : 22)
        .glassSurface(cornerRadius: 32, intense: false)
    }

    private var worlds: [WorldGroup] {
        let grouped = Dictionary(grouping: LevelCatalog.all, by: \.world)
        let worldIDs = grouped.keys.sorted()
        return worldIDs.compactMap { id in
            guard let levels = grouped[id]?.sorted(by: { $0.id < $1.id }) else { return nil }
            return WorldGroup(id: id, title: levels[0].worldTitle, levels: levels)
        }
    }
}

private struct WorldGroup: Identifiable {
    let id: Int
    let title: String
    let levels: [GameLevel]
}

struct LevelCard: View {
    let level: GameLevel
    let stars: Int
    let unlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? AppTheme.accent.opacity(0.14)
                                : AppTheme.ink.opacity(0.05)
                        )
                        .frame(width: 58, height: 58)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    unlocked ? AppTheme.accent.opacity(0.25) : Color.clear,
                                    lineWidth: 1.5
                                )
                        }

                    if unlocked {
                        Text("\(level.id)")
                            .font(.display(24, weight: .bold))
                            .foregroundStyle(AppTheme.ink)
                            .monospacedDigit()
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.inkFaint.opacity(0.7))
                    }
                }

                Text(level.title)
                    .font(.bodyRounded(13, weight: .semibold))
                    .foregroundStyle(unlocked ? AppTheme.ink : AppTheme.inkFaint.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 34)

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(index < stars ? AppTheme.star : AppTheme.inkFaint.opacity(0.28))
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(unlocked ? 0.72 : 0.4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.ink.opacity(unlocked ? 0.07 : 0.03), radius: 12, y: 5)
            }
        }
        .buttonStyle(PremiumPressStyle())
        .disabled(!unlocked)
        .accessibilityLabel("Level \(level.id), \(level.title)")
        .accessibilityValue(unlocked ? "\(stars) stars" : "Locked")
    }
}
