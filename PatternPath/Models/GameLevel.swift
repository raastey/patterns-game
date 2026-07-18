import Foundation

enum PatternFocus: String, Hashable {
    case color
    case shape

    var prompt: String {
        switch self {
        case .color: "Look at the colors"
        case .shape: "Look at the shapes"
        }
    }
}

struct GameLevel: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let focus: PatternFocus
    let slots: [PatternSlot]
    let answers: [PatternToken]
    let choices: [PatternToken]
    let starsToEarn: Int

    var blankCount: Int { slots.filter(\.isBlank).count }

    var world: Int {
        switch id {
        case 1...8: 1
        case 9...16: 2
        case 17...24: 3
        case 25...32: 4
        default: 5
        }
    }

    var worldTitle: String {
        switch world {
        case 1: "Color Path"
        case 2: "Shape Path"
        case 3: "Longer Colors"
        case 4: "Longer Shapes"
        default: "Big Patterns"
        }
    }
}

enum LevelCatalog {
    static let totalCount = 40
    static let all: [GameLevel] = makeLevels()

    static func level(id: Int) -> GameLevel? {
        all.first { $0.id == id }
    }

    private static func t(_ shape: TokenShape, _ hue: TokenHue) -> PatternToken {
        PatternToken(shape: shape, hue: hue)
    }

    private static func level(
        _ id: Int,
        title: String,
        subtitle: String,
        focus: PatternFocus,
        sequence: [PatternToken?],
        answers: [PatternToken],
        choices: [PatternToken],
        stars: Int = 3
    ) -> GameLevel {
        let slots: [PatternSlot] = sequence.map { token in
            if let token { .filled(token) } else { .blank(UUID()) }
        }
        return GameLevel(
            id: id,
            title: title,
            subtitle: subtitle,
            focus: focus,
            slots: slots,
            answers: answers.map { $0.fresh() },
            choices: choices.map { $0.fresh() },
            starsToEarn: stars
        )
    }

    /// Color-only: every bead shares one shape. Choices differ by color only.
    private static func colorLevel(
        _ id: Int,
        title: String,
        subtitle: String,
        shape: TokenShape,
        hues: [TokenHue],
        blankMask: [Bool],
        choiceHues: [TokenHue]
    ) -> GameLevel {
        precondition(hues.count == blankMask.count)
        var answers: [PatternToken] = []
        let sequence: [PatternToken?] = zip(hues, blankMask).map { hue, isBlank in
            let token = t(shape, hue)
            if isBlank {
                answers.append(token)
                return nil
            }
            return token
        }
        return level(
            id,
            title: title,
            subtitle: subtitle,
            focus: .color,
            sequence: sequence,
            answers: answers,
            choices: choiceHues.map { t(shape, $0) }
        )
    }

    /// Shape-only: every bead shares one color. Choices differ by shape only.
    private static func shapeLevel(
        _ id: Int,
        title: String,
        subtitle: String,
        hue: TokenHue,
        shapes: [TokenShape],
        blankMask: [Bool],
        choiceShapes: [TokenShape]
    ) -> GameLevel {
        precondition(shapes.count == blankMask.count)
        var answers: [PatternToken] = []
        let sequence: [PatternToken?] = zip(shapes, blankMask).map { shape, isBlank in
            let token = t(shape, hue)
            if isBlank {
                answers.append(token)
                return nil
            }
            return token
        }
        return level(
            id,
            title: title,
            subtitle: subtitle,
            focus: .shape,
            sequence: sequence,
            answers: answers,
            choices: choiceShapes.map { t($0, hue) }
        )
    }

    private static func makeLevels() -> [GameLevel] {
        let c = TokenShape.circle
        let s = TokenShape.square
        let tri = TokenShape.triangle
        let star = TokenShape.star
        let hex = TokenShape.hexagon
        let dia = TokenShape.diamond

        let coral = TokenHue.coral
        let teal = TokenHue.teal
        let sun = TokenHue.sunflower
        let peri = TokenHue.periwinkle
        let mint = TokenHue.mint
        let apri = TokenHue.apricot

        // F = filled shown, B = blank to fill
        let F = false
        let B = true

        return [
            // MARK: World 1 — Color Path (same shape: circle)
            colorLevel(1, title: "Red Blue Walk", subtitle: "What color comes next?",
                       shape: c, hues: [coral, teal, coral, teal, coral, teal],
                       blankMask: [F, F, F, F, F, B], choiceHues: [teal, sun]),

            colorLevel(2, title: "Sunny Mint", subtitle: "Keep the colors going",
                       shape: c, hues: [sun, mint, sun, mint, sun, mint],
                       blankMask: [F, F, F, F, F, B], choiceHues: [mint, coral, peri]),

            colorLevel(3, title: "Twin Colors", subtitle: "Two the same, then switch",
                       shape: c, hues: [apri, apri, teal, teal, apri, apri, teal, teal],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [teal, apri, sun]),

            colorLevel(4, title: "Three Friends", subtitle: "Three colors in a row",
                       shape: c, hues: [coral, peri, mint, coral, peri, mint],
                       blankMask: [F, F, F, F, F, B], choiceHues: [mint, sun, coral]),

            colorLevel(5, title: "Missing Spot", subtitle: "Which color belongs here?",
                       shape: c, hues: [teal, sun, teal, sun, teal, sun],
                       blankMask: [F, F, F, B, F, F], choiceHues: [sun, mint, peri]),

            colorLevel(6, title: "Soft Pairs", subtitle: "A pair, then a new color",
                       shape: c, hues: [mint, mint, coral, mint, mint, coral],
                       blankMask: [F, F, F, F, F, B], choiceHues: [coral, mint, teal]),

            colorLevel(7, title: "Apricot Wave", subtitle: "Finish the wave",
                       shape: c, hues: [apri, peri, apri, peri, apri, peri],
                       blankMask: [F, F, F, F, B, B], choiceHues: [apri, peri, sun]),

            colorLevel(8, title: "Rainbow Soft", subtitle: "Climb one color at a time",
                       shape: c, hues: [coral, apri, sun, mint, teal, peri],
                       blankMask: [F, F, F, F, B, F], choiceHues: [teal, coral, sun]),

            // MARK: World 2 — Shape Path (same color: periwinkle)
            shapeLevel(9, title: "Circle Square", subtitle: "What shape comes next?",
                       hue: peri, shapes: [c, s, c, s, c, s],
                       blankMask: [F, F, F, F, F, B], choiceShapes: [s, tri, star]),

            shapeLevel(10, title: "Three Shapes", subtitle: "Circle, triangle, square",
                       hue: peri, shapes: [c, tri, s, c, tri, s],
                       blankMask: [F, F, F, F, F, B], choiceShapes: [s, star, hex]),

            shapeLevel(11, title: "Twin Shapes", subtitle: "Two the same, then switch",
                       hue: mint, shapes: [c, c, s, s, c, c, s, s],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [s, c, tri]),

            shapeLevel(12, title: "Star Hex Dance", subtitle: "Keep the dance going",
                       hue: teal, shapes: [star, hex, star, hex, star, hex],
                       blankMask: [F, F, F, F, F, B], choiceShapes: [hex, dia, c]),

            shapeLevel(13, title: "Gap in the Line", subtitle: "Which shape fits?",
                       hue: coral, shapes: [tri, dia, tri, dia, tri, dia],
                       blankMask: [F, F, F, B, F, F], choiceShapes: [dia, s, star]),

            shapeLevel(14, title: "Diamond Circle", subtitle: "Finish the pair path",
                       hue: sun, shapes: [dia, c, dia, c, dia, c],
                       blankMask: [F, F, F, F, B, B], choiceShapes: [dia, c, hex]),

            shapeLevel(15, title: "Quiet Quartet", subtitle: "Four shapes, then again",
                       hue: apri, shapes: [c, s, tri, star, c, s, tri, star],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [tri, star, hex, dia]),

            shapeLevel(16, title: "Hex Home", subtitle: "Find the hexagon home",
                       hue: peri, shapes: [hex, c, hex, c, hex, c],
                       blankMask: [F, F, F, F, B, F], choiceShapes: [hex, s, star]),

            // MARK: World 3 — Longer Colors (still one shape)
            colorLevel(17, title: "Long Red Blue", subtitle: "A longer color walk",
                       shape: s, hues: [coral, teal, coral, teal, coral, teal, coral, teal],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [coral, teal, mint]),

            colorLevel(18, title: "Skip Color", subtitle: "Which color was skipped?",
                       shape: s, hues: [sun, mint, peri, sun, mint, peri],
                       blankMask: [F, F, F, F, B, F], choiceHues: [mint, sun, coral]),

            colorLevel(19, title: "Two Gaps", subtitle: "Fill both color gaps",
                       shape: tri, hues: [apri, teal, apri, teal, apri, teal],
                       blankMask: [F, F, B, F, F, B], choiceHues: [apri, teal, peri]),

            colorLevel(20, title: "Pair Bridge", subtitle: "Cross with matching pairs",
                       shape: star, hues: [coral, coral, mint, mint, coral, coral, mint, mint],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [mint, coral, sun]),

            colorLevel(21, title: "Soft ABC", subtitle: "Three colors take turns",
                       shape: hex, hues: [peri, sun, mint, peri, sun, mint, peri, sun],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [peri, sun, mint, coral]),

            colorLevel(22, title: "Middle Friends", subtitle: "Two colors in the middle",
                       shape: c, hues: [teal, coral, teal, coral, teal, coral],
                       blankMask: [F, B, F, B, F, F], choiceHues: [coral, teal, apri]),

            colorLevel(23, title: "Sunset Steps", subtitle: "Warm colors in order",
                       shape: dia, hues: [coral, apri, sun, coral, apri, sun],
                       blankMask: [F, F, F, F, B, B], choiceHues: [apri, sun, mint, peri]),

            colorLevel(24, title: "Cool Stream", subtitle: "Cool colors flowing by",
                       shape: s, hues: [mint, teal, peri, mint, teal, peri, mint, teal],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [mint, teal, peri, coral]),

            // MARK: World 4 — Longer Shapes (still one color)
            shapeLevel(25, title: "Long Circle Square", subtitle: "A longer shape walk",
                       hue: teal, shapes: [c, s, c, s, c, s, c, s],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [c, s, tri]),

            shapeLevel(26, title: "Skip Shape", subtitle: "Which shape was skipped?",
                       hue: mint, shapes: [star, hex, dia, star, hex, dia],
                       blankMask: [F, F, F, F, B, F], choiceShapes: [hex, c, s]),

            shapeLevel(27, title: "Two Shape Gaps", subtitle: "Fill both shape gaps",
                       hue: coral, shapes: [tri, c, tri, c, tri, c],
                       blankMask: [F, F, B, F, F, B], choiceShapes: [tri, c, star]),

            shapeLevel(28, title: "Pair Shapes", subtitle: "Two alike, then switch",
                       hue: sun, shapes: [s, s, hex, hex, s, s, hex, hex],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [hex, s, dia]),

            shapeLevel(29, title: "Shape ABC", subtitle: "Three shapes take turns",
                       hue: peri, shapes: [c, tri, star, c, tri, star, c, tri],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [c, tri, star, hex]),

            shapeLevel(30, title: "Middle Shapes", subtitle: "Two shapes in the middle",
                       hue: apri, shapes: [dia, hex, dia, hex, dia, hex],
                       blankMask: [F, B, F, B, F, F], choiceShapes: [hex, dia, c]),

            shapeLevel(31, title: "Garden Shapes", subtitle: "Grow the shape garden",
                       hue: mint, shapes: [c, s, tri, hex, c, s, tri, hex],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [tri, hex, star, dia]),

            shapeLevel(32, title: "Star Trail", subtitle: "Stars and diamonds only",
                       hue: coral, shapes: [star, dia, star, dia, star, dia, star, dia],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [star, dia, hex]),

            // MARK: World 5 — Big Patterns (still single attribute, longer / more blanks)
            colorLevel(33, title: "Big Color Bridge", subtitle: "Three colors to place",
                       shape: c, hues: [coral, teal, sun, coral, teal, sun, coral, teal, sun],
                       blankMask: [F, F, F, F, F, F, B, B, B], choiceHues: [coral, teal, sun, mint]),

            shapeLevel(34, title: "Big Shape Bridge", subtitle: "Three shapes to place",
                       hue: peri, shapes: [c, s, tri, c, s, tri, c, s, tri],
                       blankMask: [F, F, F, F, F, F, B, B, B], choiceShapes: [c, s, tri, star]),

            colorLevel(35, title: "Repair the Colors", subtitle: "Fix both broken spots",
                       shape: hex, hues: [mint, apri, mint, apri, mint, apri, mint, apri],
                       blankMask: [F, F, B, F, F, B, F, F], choiceHues: [mint, apri, coral]),

            shapeLevel(36, title: "Repair the Shapes", subtitle: "Fix both broken spots",
                       hue: teal, shapes: [star, c, star, c, star, c, star, c],
                       blankMask: [F, F, B, F, F, B, F, F], choiceShapes: [star, c, dia]),

            colorLevel(37, title: "Festival Colors", subtitle: "Four colors in the parade",
                       shape: s, hues: [coral, sun, teal, peri, coral, sun, teal, peri],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [teal, peri, mint, apri]),

            shapeLevel(38, title: "Festival Shapes", subtitle: "Four shapes in the parade",
                       hue: sun, shapes: [c, tri, hex, dia, c, tri, hex, dia],
                       blankMask: [F, F, F, F, F, F, B, B], choiceShapes: [hex, dia, s, star]),

            colorLevel(39, title: "Gentle Finale Colors", subtitle: "A long soft color song",
                       shape: star, hues: [coral, mint, peri, coral, mint, peri, coral, mint, peri],
                       blankMask: [F, F, F, F, F, F, B, B, B], choiceHues: [coral, mint, peri, sun]),

            shapeLevel(40, title: "Gentle Finale Shapes", subtitle: "A long soft shape song",
                       hue: mint, shapes: [c, s, tri, star, c, s, tri, star, c, s],
                       blankMask: [F, F, F, F, F, F, F, F, B, B], choiceShapes: [c, s, hex, dia])
        ]
    }
}
