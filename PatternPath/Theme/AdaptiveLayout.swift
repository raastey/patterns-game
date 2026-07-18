import SwiftUI

/// Shared layout metrics for portrait/landscape across iPhone and iPad.
struct AdaptiveLayout {
    let size: CGSize
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?

    var isLandscape: Bool { size.width > size.height }
    var isCompactWidth: Bool { horizontalSizeClass == .compact }
    var isCompactHeight: Bool { verticalSizeClass == .compact }
    /// Short landscape (typical iPhone landscape) needs tighter chrome.
    var isShortLandscape: Bool { isLandscape && (isCompactHeight || size.height < 500) }
    var isRegularPad: Bool { horizontalSizeClass == .regular && !isCompactWidth }

    var horizontalPadding: CGFloat {
        if isShortLandscape { return 16 }
        if isCompactWidth { return 20 }
        return isLandscape ? 36 : 32
    }

    var playTitleSize: CGFloat {
        if isShortLandscape { return 22 }
        if isCompactWidth { return 28 }
        return isLandscape ? 32 : 36
    }

    var homeTitleSize: CGFloat {
        if isShortLandscape { return 36 }
        if isCompactWidth { return 44 }
        return 62
    }

    func ribbonTokenSize(slotCount: Int, columns: Int = 3) -> CGFloat {
        let cols = max(columns, 1)
        let rows = max(1, Int(ceil(Double(slotCount) / Double(cols))))
        let heightBudget = isLandscape
            ? size.height * (rows >= 3 ? 0.42 : 0.36)
            : size.height * (rows >= 3 ? 0.34 : 0.28)
        let widthBudget = size.width * 0.78 / CGFloat(cols)
        let byHeight = heightBudget / CGFloat(rows) * 0.72
        let byWidth = widthBudget * 0.72
        var base = min(byHeight, byWidth)
        base = min(max(base, 40), isShortLandscape ? 58 : (isCompactWidth ? 68 : 82))
        if rows >= 3 { base = min(base, isShortLandscape ? 48 : 62) }
        return base
    }

    func choiceTokenSize(choiceCount: Int) -> CGFloat {
        let heightBudget = isLandscape ? size.height * 0.2 : size.width * 0.17
        var base = min(max(heightBudget, 52), isShortLandscape ? 60 : (isCompactWidth ? 70 : 86))
        if choiceCount >= 5 { base -= 10 }
        return max(48, base)
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
