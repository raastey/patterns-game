import SwiftUI

struct LevelMapView: View {
    @Environment(ProgressStore.self) private var progress
    let onSelect: (Int) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            SkyBackground(theme: WorldTheme.forLevelID(max(1, progress.highestUnlocked)))

            AdaptiveReader { layout in
                VStack(spacing: 0) {
                    header(layout)
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.top, layout.isShortLandscape ? 8 : 14)
                        .padding(.bottom, layout.isShortLandscape ? 8 : 12)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: layout.isShortLandscape ? 14 : 22) {
                            GarageBaysView(compact: layout.isShortLandscape)
                                .padding(layout.isShortLandscape ? 12 : 16)
                                .glassSurface(cornerRadius: 22, intense: false)

                            ForEach(worlds, id: \.id) { world in
                                worldSection(world, layout: layout)
                            }
                        }
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.bottom, 36)
                    }
                }
            }
        }
    }

    private func header(_ layout: AdaptiveLayout) -> some View {
        HStack(spacing: 8) {
            ToolbarChip(title: "Home", systemImage: "chevron.left", action: onBack)

            Spacer(minLength: 4)

            Text("Levels")
                .font(.display(layout.isShortLandscape ? 22 : (layout.isCompactWidth ? 26 : 34), weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                StatusChip(
                    text: "\(progress.totalStars)",
                    systemImage: "star.fill",
                    tint: AppTheme.star
                )
                MuteButton()
                if !layout.isShortLandscape {
                    HapticsButton()
                }
            }
        }
    }

    private func worldSection(_ world: WorldGroup, layout: AdaptiveLayout) -> some View {
        let columns = [
            GridItem(
                .adaptive(minimum: layout.levelGridMinimum, maximum: layout.levelGridMaximum),
                spacing: 12
            )
        ]
        let theme = WorldTheme.forWorld(world.id)
        let filled = progress.clearedCount(inWorld: world.id)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text(world.title)
                    .font(.display(layout.isShortLandscape ? 18 : 22, weight: .bold))
                    .foregroundStyle(AppTheme.ink)

                Text("\(filled)/10")
                    .font(.captionRounded(12))
                    .foregroundStyle(AppTheme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background {
                        Capsule().fill(theme.lamp.opacity(0.22))
                    }

                Text(theme.tagline)
                    .font(.captionRounded(11))
                    .foregroundStyle(AppTheme.inkFaint)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(world.levels) { level in
                    LevelCard(
                        level: level,
                        stars: progress.stars(for: level.id),
                        unlocked: progress.isUnlocked(level.id),
                        compact: layout.isShortLandscape
                    ) {
                        SoundPlayer.shared.playTap()
                        HapticsPlayer.shared.navigate()
                        onSelect(level.id)
                    }
                }
            }
        }
        .padding(layout.isShortLandscape ? 14 : (layout.isCompactWidth ? 16 : 22))
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(theme.skyMid.opacity(0.16))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
                .shadow(color: AppTheme.ink.opacity(0.08), radius: 24, y: 10)
        }
    }

    private var worlds: [WorldGroup] {
        let grouped = Dictionary(grouping: LevelCatalog.all, by: \.world)
        let worldIDs = grouped.keys.sorted()
        return worldIDs.compactMap { id in
            guard let levels = grouped[id]?.sorted(by: { $0.id < $1.id }) else { return nil }
            return WorldGroup(id: id, title: WorldTheme.forWorld(id).title, levels: levels)
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
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: compact ? 6 : 10) {
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? AppTheme.accent.opacity(0.14)
                                : AppTheme.ink.opacity(0.05)
                        )
                        .frame(width: compact ? 48 : 58, height: compact ? 48 : 58)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    unlocked
                                        ? (stars > 0 && stars < 3
                                            ? AppTheme.star.opacity(0.85)
                                            : AppTheme.accent.opacity(0.25))
                                        : Color.clear,
                                    lineWidth: stars > 0 && stars < 3 ? 2.5 : 1.5
                                )
                        }

                    if unlocked {
                        Text("\(level.id)")
                            .font(.display(compact ? 20 : 24, weight: .bold))
                            .foregroundStyle(AppTheme.ink)
                            .monospacedDigit()
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: compact ? 15 : 18, weight: .semibold))
                            .foregroundStyle(AppTheme.inkFaint.opacity(0.7))
                    }
                }

                Text(level.title)
                    .font(.bodyRounded(compact ? 11 : 13, weight: .semibold))
                    .foregroundStyle(unlocked ? AppTheme.ink : AppTheme.inkFaint.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: compact ? 28 : 34)

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.system(size: compact ? 10 : 12, weight: .bold))
                            .foregroundStyle(index < stars ? AppTheme.star : AppTheme.inkFaint.opacity(0.28))
                    }
                }
            }
            .padding(compact ? 10 : 14)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(unlocked ? 0.72 : 0.4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.ink.opacity(unlocked ? 0.07 : 0.03), radius: 12, y: 5)
            }
        }
        .buttonStyle(PremiumPressStyle())
        .disabled(!unlocked)
        .accessibilityLabel("Level \(level.id), \(level.title)")
        .accessibilityValue(
            unlocked
                ? (stars > 0 && stars < 3 ? "\(stars) stars, try for 3" : "\(stars) stars")
                : "Locked"
        )
    }
}
