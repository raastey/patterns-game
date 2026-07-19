import SwiftUI

enum ToyKind: String, CaseIterable, Codable, Hashable {
    // Cars
    case raceCar
    case sedan
    case sportsSedan
    case hatchback
    case coupe
    case compactCar
    case cityCar
    case basicCar
    case wagon
    case taxi
    case suv
    case luxurySUV
    case futureRacer
    case goKart
    // Classics (CC0 OpenGameArt)
    case modelT
    case topolino
    case classicSedan
    // Work & street
    case jeep
    case pickup
    case bus
    case delivery
    case dumpTruck
    case garbageTruck
    case boxTruck
    case tankerTruck
    case semiTruck
    case carCarrier
    case tractor
    case loader
    // Rescue
    case fireTruck
    case policeCar
    case ambulance
    // Fun
    case robot
    case rocket

    var accessibilityName: String {
        switch self {
        case .raceCar: "race car"
        case .sedan: "sedan"
        case .sportsSedan: "sports sedan"
        case .hatchback: "hatchback"
        case .coupe: "coupe"
        case .compactCar: "compact car"
        case .cityCar: "city car"
        case .basicCar: "car"
        case .wagon: "wagon"
        case .taxi: "taxi"
        case .suv: "SUV"
        case .luxurySUV: "luxury SUV"
        case .futureRacer: "future racer"
        case .goKart: "go-kart"
        case .modelT: "Model T"
        case .topolino: "Topolino"
        case .classicSedan: "classic sedan"
        case .jeep: "jeep"
        case .pickup: "pickup"
        case .bus: "bus"
        case .delivery: "delivery van"
        case .dumpTruck: "dump truck"
        case .garbageTruck: "garbage truck"
        case .boxTruck: "box truck"
        case .tankerTruck: "tanker truck"
        case .semiTruck: "semi truck"
        case .carCarrier: "car carrier"
        case .tractor: "tractor"
        case .loader: "loader"
        case .fireTruck: "fire truck"
        case .policeCar: "police car"
        case .ambulance: "ambulance"
        case .robot: "robot"
        case .rocket: "rocket"
        }
    }

    var shortName: String {
        switch self {
        case .raceCar: "Race"
        case .sedan: "Sedan"
        case .sportsSedan: "Sport Sedan"
        case .hatchback: "Hatch"
        case .coupe: "Coupe"
        case .compactCar: "Compact"
        case .cityCar: "City"
        case .basicCar: "Car"
        case .wagon: "Wagon"
        case .taxi: "Taxi"
        case .suv: "SUV"
        case .luxurySUV: "Lux SUV"
        case .futureRacer: "Future"
        case .goKart: "Kart"
        case .modelT: "Model T"
        case .topolino: "Topolino"
        case .classicSedan: "Classic"
        case .jeep: "Jeep"
        case .pickup: "Pickup"
        case .bus: "Bus"
        case .delivery: "Delivery"
        case .dumpTruck: "Dump"
        case .garbageTruck: "Garbage"
        case .boxTruck: "Box"
        case .tankerTruck: "Tanker"
        case .semiTruck: "Semi"
        case .carCarrier: "Carrier"
        case .tractor: "Tractor"
        case .loader: "Loader"
        case .fireTruck: "Fire"
        case .policeCar: "Police"
        case .ambulance: "Ambulance"
        case .robot: "Robot"
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
