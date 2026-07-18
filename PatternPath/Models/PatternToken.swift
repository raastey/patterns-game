import SwiftUI

enum TokenShape: String, CaseIterable, Codable, Hashable {
    case circle
    case square
    case triangle
    case star
    case hexagon
    case diamond

    var accessibilityName: String {
        rawValue
    }
}

enum TokenHue: String, CaseIterable, Codable, Hashable {
    case coral
    case teal
    case sunflower
    case periwinkle
    case mint
    case apricot

    var color: Color {
        switch self {
        case .coral: AppTheme.coral
        case .teal: AppTheme.teal
        case .sunflower: AppTheme.sunflower
        case .periwinkle: AppTheme.periwinkle
        case .mint: AppTheme.mint
        case .apricot: AppTheme.apricot
        }
    }

    var accessibilityName: String {
        rawValue
    }
}

struct PatternToken: Identifiable, Hashable, Codable {
    let id: UUID
    let shape: TokenShape
    let hue: TokenHue

    init(id: UUID = UUID(), shape: TokenShape, hue: TokenHue) {
        self.id = id
        self.shape = shape
        self.hue = hue
    }

    var accessibilityLabel: String {
        "\(hue.accessibilityName) \(shape.accessibilityName)"
    }

    func matches(_ other: PatternToken) -> Bool {
        shape == other.shape && hue == other.hue
    }

    func fresh() -> PatternToken {
        PatternToken(shape: shape, hue: hue)
    }
}

enum PatternSlot: Identifiable, Hashable {
    case filled(PatternToken)
    case blank(UUID)

    var id: UUID {
        switch self {
        case .filled(let token): token.id
        case .blank(let id): id
        }
    }

    var token: PatternToken? {
        if case .filled(let token) = self { return token }
        return nil
    }

    var isBlank: Bool {
        if case .blank = self { return true }
        return false
    }
}
