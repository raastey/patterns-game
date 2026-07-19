import SwiftUI

/// Shared layout metrics for portrait/landscape across iPhone and iPad.
struct AdaptiveLayout {
    let size: CGSize
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?

    var isLandscape: Bool { size.width > size.height }
    var isCompactWidth: Bool { horizontalSizeClass == .compact }
    var isCompactHeight: Bool { verticalSizeClass == .compact }
    var isShortLandscape: Bool { isLandscape && (isCompactHeight || size.height < 500) }
    var isRegularPad: Bool { horizontalSizeClass == .regular && !isCompactWidth }

    var horizontalPadding: CGFloat {
        if isShortLandscape { return 12 }
        if isCompactWidth { return 16 }
        return isLandscape ? 24 : 20
    }

    var playTitleSize: CGFloat {
        if isShortLandscape { return 18 }
        if isCompactWidth { return 22 }
        return isLandscape ? 24 : 26
    }

    var homeTitleSize: CGFloat {
        if isShortLandscape { return 36 }
        if isCompactWidth { return 44 }
        return 62
    }

    /// Token size from the board's actual offered size (preferred path).
    static func boardTokenSize(
        boardSize: CGSize,
        slotCount: Int,
        columns: Int
    ) -> CGFloat {
        let cols = max(columns, 1)
        let rows = max(1, Int(ceil(Double(slotCount) / Double(cols))))
        let spacingFactor: CGFloat = 0.16
        let padFactor: CGFloat = 0.12

        let usableW = boardSize.width * (1 - padFactor * 2)
        let usableH = boardSize.height * (1 - padFactor * 2)
        guard usableW > 40, usableH > 40 else { return 56 }

        let cellW = usableW / (CGFloat(cols) + spacingFactor * CGFloat(cols - 1))
        let cellH = usableH / (CGFloat(rows) + spacingFactor * CGFloat(rows - 1))
        let raw = min(cellW, cellH) * 0.92
        return min(max(raw, 48), 160)
    }

    /// Fallback when board geometry is not yet available.
    func ribbonTokenSize(slotCount: Int, columns: Int = 3) -> CGFloat {
        let cols = max(columns, 1)
        let rows = max(1, Int(ceil(Double(slotCount) / Double(cols))))
        let heightBudget = isLandscape
            ? size.height * (rows >= 3 ? 0.55 : 0.58)
            : size.height * (rows >= 3 ? 0.48 : 0.52)
        let widthBudget = (size.width - horizontalPadding * 2) / CGFloat(cols)
        let byHeight = heightBudget / CGFloat(rows) * 0.78
        let byWidth = widthBudget * 0.78
        return min(max(min(byHeight, byWidth), 52), isShortLandscape ? 88 : 140)
    }

    func choiceTokenSize(choiceCount: Int, shelfWidth: CGFloat? = nil) -> CGFloat {
        let width = shelfWidth ?? (size.width - horizontalPadding * 2)
        let count = max(choiceCount, 1)
        let byWidth = width / CGFloat(count) * 0.72
        let heightBudget = isLandscape ? size.height * 0.22 : size.height * 0.14
        var base = min(byWidth, heightBudget)
        base = min(max(base, 56), isShortLandscape ? 72 : 110)
        if choiceCount >= 5 { base = min(base, 78) }
        return base
    }

    var levelGridMinimum: CGFloat {
        if isShortLandscape { return 100 }
        if isCompactWidth { return 108 }
        return isLandscape ? 130 : 148
    }

    var levelGridMaximum: CGFloat {
        if isShortLandscape { return 130 }
        if isCompactWidth { return 140 }
        return isLandscape ? 170 : 180
    }
}

struct AdaptiveReader<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ViewBuilder var content: (AdaptiveLayout) -> Content

    var body: some View {
        GeometryReader { geo in
            let layout = AdaptiveLayout(
                size: geo.size,
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass
            )
            content(layout)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
