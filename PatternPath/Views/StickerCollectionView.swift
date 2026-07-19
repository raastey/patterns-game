import SwiftUI

struct StickerCollectionView: View {
    @Environment(ProgressStore.self) private var progress
    let onClose: () -> Void

    var body: some View {
        ZStack {
            SkyBackground(theme: .superGarage)

            AdaptiveReader { layout in
                VStack(spacing: layout.isShortLandscape ? 10 : 16) {
                    HStack {
                        ToolbarChip(title: "Back", systemImage: "chevron.left", action: onClose)
                        Spacer()
                        Text("Sticker Garage")
                            .font(.display(layout.isShortLandscape ? 22 : 28, weight: .bold))
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        StatusChip(
                            text: "\(progress.unlockedStickers.count)/\(StickerCatalog.all.count)",
                            systemImage: "star.fill",
                            tint: AppTheme.star
                        )
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.top, layout.isShortLandscape ? 8 : 14)

                    Text("Clear 5 levels to unlock each sticker.")
                        .font(.bodyRounded(layout.isShortLandscape ? 14 : 16, weight: .medium))
                        .foregroundStyle(AppTheme.inkSoft)
                        .padding(.horizontal, layout.horizontalPadding)

                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: layout.isCompactWidth ? 120 : 140), spacing: 14)
                            ],
                            spacing: 14
                        ) {
                            ForEach(StickerCatalog.all) { sticker in
                                stickerCard(sticker, compact: layout.isShortLandscape)
                            }
                        }
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.bottom, 28)
                    }
                }
            }
        }
    }

    private func stickerCard(_ sticker: GarageSticker, compact: Bool) -> some View {
        let unlocked = progress.isStickerUnlocked(milestone: sticker.milestone)

        return VStack(spacing: compact ? 8 : 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(unlocked ? AppTheme.accent.opacity(0.12) : AppTheme.ink.opacity(0.05))
                    .frame(height: compact ? 88 : 110)

                if unlocked {
                    TokenView(token: sticker.token, size: compact ? 56 : 68)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: compact ? 22 : 28, weight: .semibold))
                        .foregroundStyle(AppTheme.inkFaint.opacity(0.65))
                }
            }

            Text(unlocked ? sticker.label : "Level \(sticker.milestone)")
                .font(.bodyRounded(compact ? 13 : 15, weight: .bold))
                .foregroundStyle(unlocked ? AppTheme.ink : AppTheme.inkFaint)
                .lineLimit(1)

            Text(unlocked ? "Unlocked" : "Clear level \(sticker.milestone)")
                .font(.captionRounded(compact ? 10 : 11))
                .foregroundStyle(AppTheme.inkFaint)
        }
        .padding(compact ? 12 : 16)
        .glassSurface(cornerRadius: 24, intense: unlocked)
        .accessibilityLabel(unlocked ? "\(sticker.label) sticker unlocked" : "Sticker locked, clear level \(sticker.milestone)")
    }
}
