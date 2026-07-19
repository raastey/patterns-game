import SwiftUI

struct PatternRibbon: View {
    let slots: [PatternSlot]
    var columns: Int = 3
    var theme: WorldTheme = .colorGarage
    var activeBlankIndex: Int?
    var shakeBlankIndex: Int?
    var lastPlacedIndex: Int?
    /// When nil, size is derived from the board's GeometryReader.
    var tokenSize: CGFloat? = nil

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
        GeometryReader { geo in
            let size = resolvedTokenSize(in: geo.size)
            let spacing = size * 0.16

            ZStack {
                parkingLot(cornerRadius: min(geo.size.width, geo.size.height) * 0.08)

                VStack(spacing: spacing) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: spacing) {
                            ForEach(row, id: \.index) { item in
                                slotView(index: item.index, slot: item.slot, size: size)
                            }
                        }
                    }
                }
                .padding(size * 0.28)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Toy garage board, \(rows.count) rows")
    }

    private func resolvedTokenSize(in boardSize: CGSize) -> CGFloat {
        if let tokenSize { return tokenSize }
        return AdaptiveLayout.boardTokenSize(
            boardSize: boardSize,
            slotCount: slots.count,
            columns: columns
        )
    }

    @ViewBuilder
    private func slotView(index: Int, slot: PatternSlot, size: CGFloat) -> some View {
        switch slot {
        case .filled(let token):
            TokenView(
                token: token,
                size: size,
                isPlaced: lastPlacedIndex == index
            )
            .transition(.scale.combined(with: .opacity))
        case .blank:
            BlankSlotView(
                size: size,
                isActive: activeBlankIndex == index,
                isShaking: shakeBlankIndex == index
            )
        }
    }

    private func parkingLot(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.trayGradient)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius * 0.85, style: .continuous)
                    .strokeBorder(
                        theme.laneLine.opacity(0.38),
                        style: StrokeStyle(lineWidth: 3, dash: [10, 8])
                    )
                    .padding(14)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.28),
                                Color.black.opacity(0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [theme.lamp.opacity(0.22), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .shadow(color: Color.black.opacity(0.35), radius: 18, y: 10)
            .shadow(color: Color.black.opacity(0.12), radius: 3, y: 1)
    }
}
