import SwiftUI

struct GarageBaysView: View {
    @Environment(ProgressStore.self) private var progress
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 6 : 10) {
            ForEach(WorldTheme.all) { world in
                bay(for: world)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private func bay(for world: WorldTheme) -> some View {
        let fill = progress.worldFill(worldID: world.id)
        let lit = fill > 0

        return VStack(spacing: compact ? 4 : 6) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                    .fill(world.trayDeep.opacity(0.85))
                    .overlay {
                        RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    }

                // Filling asphalt
                RoundedRectangle(cornerRadius: compact ? 6 : 8, style: .continuous)
                    .fill(world.trayGradient)
                    .frame(height: max(4, (compact ? 28 : 36) * fill))
                    .padding(2)

                // Lamp flicker when partially filled
                Capsule()
                    .fill(world.lamp.opacity(lit ? 0.55 + fill * 0.35 : 0.12))
                    .frame(width: compact ? 14 : 18, height: compact ? 3 : 4)
                    .offset(y: compact ? -14 : -18)

                if fill >= 1 {
                    TokenView(token: mascot(for: world.id), size: compact ? 16 : 20)
                        .offset(y: compact ? -2 : -3)
                }
            }
            .frame(width: compact ? 36 : 48, height: compact ? 36 : 46)

            Text(shortName(world.title))
                .font(.captionRounded(compact ? 8 : 10))
                .foregroundStyle(AppTheme.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func mascot(for worldID: Int) -> PatternToken {
        switch worldID {
        case 1: PatternToken(toy: .raceCar, hue: .coral)
        case 2: PatternToken(toy: .bus, hue: .sunflower)
        case 3: PatternToken(toy: .modelT, hue: .apricot)
        case 4: PatternToken(toy: .fireTruck, hue: .mint)
        default: PatternToken(toy: .jeep, hue: .periwinkle)
        }
    }

    private func shortName(_ title: String) -> String {
        title.split(separator: " ").first.map(String.init) ?? title
    }

    private var accessibilitySummary: String {
        let parts = WorldTheme.all.map { world in
            let n = progress.clearedCount(inWorld: world.id)
            return "\(world.title) \(n) of 10"
        }
        return "Garage bays: " + parts.joined(separator: ", ")
    }
}

struct StickerStripView: View {
    @Environment(ProgressStore.self) private var progress
    var compact: Bool = false
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: compact ? 8 : 10) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: compact ? 14 : 16, weight: .bold))
                    .foregroundStyle(AppTheme.accentDeep)

                Text("Stickers")
                    .font(.bodyRounded(compact ? 14 : 16, weight: .bold))
                    .foregroundStyle(AppTheme.ink)

                Text("\(progress.unlockedStickers.count)/\(StickerCatalog.all.count)")
                    .font(.captionRounded(compact ? 11 : 12))
                    .foregroundStyle(AppTheme.inkFaint)

                Spacer(minLength: 4)

                HStack(spacing: -8) {
                    ForEach(progress.unlockedStickers.suffix(4)) { sticker in
                        TokenView(token: sticker.token, size: compact ? 22 : 26)
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                            }
                    }
                }
            }
            .padding(.horizontal, compact ? 12 : 16)
            .padding(.vertical, compact ? 10 : 12)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(PremiumPressStyle())
        .accessibilityLabel("Stickers, \(progress.unlockedStickers.count) of \(StickerCatalog.all.count) unlocked")
    }
}
