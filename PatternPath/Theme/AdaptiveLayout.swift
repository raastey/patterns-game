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
    var isRegularPad: Bool { horizontalSizeClass == .regular && size.width >= 700 }

    var horizontalPadding: CGFloat {
        if isShortLandscape { return 12 }
        if isCompactWidth { return 16 }
        return isLandscape ? 24 : 20
    }

    /// Play chrome (top bar / title) inset.
    var playChromePadding: CGFloat {
        if isShortLandscape { return 12 }
        if isCompactWidth { return 14 }
        return isRegularPad ? 20 : 16
    }

    /// Board + shelf inset. Tight so asphalt reads full-bleed.
    var playBoardPadding: CGFloat {
        if isShortLandscape { return 8 }
        if isCompactWidth { return 10 }
        return isRegularPad ? 14 : 12
    }

    var playTopPadding: CGFloat {
        isShortLandscape ? 4 : 8
    }

    var playBottomPadding: CGFloat {
        isShortLandscape ? 6 : 10
    }

    var playTitleSize: CGFloat {
        if isShortLandscape { return 18 }
        if isCompactWidth { return 22 }
        return isLandscape ? 24 : (isRegularPad ? 28 : 26)
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
        let spacingFactor: CGFloat = 0.14
        let padFactor: CGFloat = 0.06

        let usableW = boardSize.width * (1 - padFactor * 2)
        let usableH = boardSize.height * (1 - padFactor * 2)
        guard usableW > 40, usableH > 40 else { return 64 }

        let cellW = usableW / (CGFloat(cols) + spacingFactor * CGFloat(cols - 1))
        let cellH = usableH / (CGFloat(rows) + spacingFactor * CGFloat(rows - 1))
        let raw = min(cellW, cellH) * 0.96
        // iPad portrait boards are tall; let tokens grow so the grid fills the lot.
        return min(max(raw, 56), 220)
    }

    /// Fallback when board geometry is not yet available.
    func ribbonTokenSize(slotCount: Int, columns: Int = 3) -> CGFloat {
        let cols = max(columns, 1)
        let rows = max(1, Int(ceil(Double(slotCount) / Double(cols))))
        let heightBudget = isLandscape
            ? size.height * (rows >= 3 ? 0.55 : 0.58)
            : size.height * (rows >= 3 ? 0.52 : 0.58)
        let widthBudget = (size.width - playBoardPadding * 2) / CGFloat(cols)
        let byHeight = heightBudget / CGFloat(rows) * 0.82
        let byWidth = widthBudget * 0.82
        let cap: CGFloat = isShortLandscape ? 96 : (isRegularPad ? 200 : 150)
        return min(max(min(byHeight, byWidth), 56), cap)
    }

    func choiceTokenSize(choiceCount: Int, shelfWidth: CGFloat? = nil) -> CGFloat {
        let width = shelfWidth ?? (size.width - playBoardPadding * 2)
        let count = max(choiceCount, 1)
        let byWidth = width / CGFloat(count) * 0.78
        let heightBudget = isLandscape
            ? size.height * 0.24
            : size.height * (isRegularPad ? 0.13 : 0.15)
        var base = min(byWidth, heightBudget)
        let cap: CGFloat = isShortLandscape ? 76 : (isRegularPad ? 120 : 104)
        base = min(max(base, 58), cap)
        if choiceCount >= 5 { base = min(base, isRegularPad ? 96 : 82) }
        if choiceCount >= 6 { base = min(base, isRegularPad ? 88 : 74) }
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
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
    }
}
