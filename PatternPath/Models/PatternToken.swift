import SwiftUI

enum ToyKind: String, CaseIterable, Codable, Hashable {
    case raceCar
    case fireTruck
    case policeCar
    case dumpTruck
    case carCarrier
    case robot
    case ambulance
    case rocket

    var accessibilityName: String {
        switch self {
        case .raceCar: "race car"
        case .fireTruck: "fire truck"
        case .policeCar: "police car"
        case .dumpTruck: "dump truck"
        case .carCarrier: "car carrier"
        case .robot: "robot"
        case .ambulance: "ambulance"
        case .rocket: "rocket"
        }
    }

    var shortName: String {
        switch self {
        case .raceCar: "Car"
        case .fireTruck: "Fire"
        case .policeCar: "Police"
        case .dumpTruck: "Dump"
        case .carCarrier: "Carrier"
        case .robot: "Robot"
        case .ambulance: "Ambulance"
        case .rocket: "Rocket"
        }
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

    var accessibilityName: String { rawValue }
}

struct PatternToken: Identifiable, Hashable, Codable {
    let id: UUID
    let toy: ToyKind
    let hue: TokenHue

    init(id: UUID = UUID(), toy: ToyKind, hue: TokenHue) {
        self.id = id
        self.toy = toy
        self.hue = hue
    }

    var accessibilityLabel: String {
        "\(hue.accessibilityName) \(toy.accessibilityName)"
    }

    func matches(_ other: PatternToken) -> Bool {
        toy == other.toy && hue == other.hue
    }

    func fresh() -> PatternToken {
        PatternToken(toy: toy, hue: hue)
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
