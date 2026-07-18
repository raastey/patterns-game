import SwiftUI

struct PatternRibbon: View {
    let slots: [PatternSlot]
    var columns: Int = 3
    var activeBlankIndex: Int?
    var shakeBlankIndex: Int?
    var lastPlacedIndex: Int?
    var tokenSize: CGFloat = 72

    private var rows: [[(index: Int, slot: PatternSlot)]] {
        let cols = max(columns, 1)
        let items = slots.enumerated().map { (index: $0.offset, slot: $0.element) }
        var result: [[(index: Int, slot: PatternSlot)]] = []
        var i = 0
        while i < items.count {
            let end = min(i + cols, items.count)
            result.append(Array(items[i..<end]))
            i = end
        }
        return result
    }

    var body: some View {
        let spacing = tokenSize * 0.18
        let padH = tokenSize * 0.38
        let padV = tokenSize * 0.32

        VStack(spacing: spacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.index) { item in
                        slotView(index: item.index, slot: item.slot)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, padH)
        .padding(.vertical, padV)
        .background {
            boardTray
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Toy garage board, \(rows.count) rows")
    }

    @ViewBuilder
    private func slotView(index: Int, slot: PatternSlot) -> some View {
        switch slot {
        case .filled(let token):
            TokenView(
                token: token,
                size: tokenSize,
                isPlaced: lastPlacedIndex == index
            )
            .transition(.scale.combined(with: .opacity))
        case .blank:
            BlankSlotView(
                size: tokenSize,
                isActive: activeBlankIndex == index,
                isShaking: shakeBlankIndex == index
            )
        }
    }

    private var boardTray: some View {
        let radius = tokenSize * 0.42
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(AppTheme.trayGradient)
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.28),
                                Color.clear,
                                Color.black.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius * 0.85, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 3)
                    .padding(6)
                    .blur(radius: 0.5)
            }
            .shadow(color: AppTheme.trayDeep.opacity(0.35), radius: 22, y: 12)
            .shadow(color: AppTheme.ink.opacity(0.08), radius: 4, y: 1)
    }
}
