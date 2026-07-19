import SwiftUI

struct WorldTheme: Equatable, Identifiable {
    let id: Int
    let title: String
    let tagline: String
    let skyDeep: Color
    let skyMid: Color
    let skyLight: Color
    let sand: Color
    let trayLight: Color
    let trayMid: Color
    let trayDeep: Color
    let lamp: Color
    let laneLine: Color

    var trayGradient: LinearGradient {
        LinearGradient(
            colors: [trayLight, trayMid, trayDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var skyGradient: LinearGradient {
        LinearGradient(
            colors: [skyDeep, skyMid, sand],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func forWorld(_ id: Int) -> WorldTheme {
        switch id {
        case 1: colorGarage
        case 2: streetParade
        case 3: classicLane
        case 4: rescueYard
        default: superGarage
        }
    }

    static func forLevelID(_ levelID: Int) -> WorldTheme {
        forWorld(GameLevel.worldID(for: levelID))
    }

    static let colorGarage = WorldTheme(
        id: 1,
        title: "Color Garage",
        tagline: "Warm shop light",
        skyDeep: Color(red: 0.30, green: 0.44, blue: 0.54),
        skyMid: Color(red: 0.50, green: 0.64, blue: 0.70),
        skyLight: Color(red: 0.80, green: 0.86, blue: 0.88),
        sand: Color(red: 0.94, green: 0.88, blue: 0.74),
        trayLight: Color(red: 0.44, green: 0.46, blue: 0.50),
        trayMid: Color(red: 0.32, green: 0.34, blue: 0.38),
        trayDeep: Color(red: 0.22, green: 0.24, blue: 0.28),
        lamp: Color(red: 1.0, green: 0.64, blue: 0.30),
        laneLine: Color(red: 0.96, green: 0.84, blue: 0.30)
    )

    static let streetParade = WorldTheme(
        id: 2,
        title: "Street Parade",
        tagline: "City asphalt",
        skyDeep: Color(red: 0.22, green: 0.48, blue: 0.62),
        skyMid: Color(red: 0.42, green: 0.68, blue: 0.78),
        skyLight: Color(red: 0.72, green: 0.88, blue: 0.92),
        sand: Color(red: 0.90, green: 0.90, blue: 0.86),
        trayLight: Color(red: 0.38, green: 0.40, blue: 0.46),
        trayMid: Color(red: 0.26, green: 0.28, blue: 0.34),
        trayDeep: Color(red: 0.16, green: 0.18, blue: 0.24),
        lamp: Color(red: 0.45, green: 0.78, blue: 0.95),
        laneLine: Color(red: 0.98, green: 0.98, blue: 0.92)
    )

    static let classicLane = WorldTheme(
        id: 3,
        title: "Classic Lane",
        tagline: "Amber evening",
        skyDeep: Color(red: 0.42, green: 0.36, blue: 0.48),
        skyMid: Color(red: 0.68, green: 0.52, blue: 0.42),
        skyLight: Color(red: 0.90, green: 0.78, blue: 0.58),
        sand: Color(red: 0.96, green: 0.86, blue: 0.62),
        trayLight: Color(red: 0.48, green: 0.42, blue: 0.36),
        trayMid: Color(red: 0.36, green: 0.30, blue: 0.26),
        trayDeep: Color(red: 0.24, green: 0.20, blue: 0.18),
        lamp: Color(red: 1.0, green: 0.72, blue: 0.28),
        laneLine: Color(red: 0.98, green: 0.78, blue: 0.32)
    )

    static let rescueYard = WorldTheme(
        id: 4,
        title: "Rescue Yard",
        tagline: "Cool night bay",
        skyDeep: Color(red: 0.18, green: 0.28, blue: 0.48),
        skyMid: Color(red: 0.32, green: 0.48, blue: 0.68),
        skyLight: Color(red: 0.62, green: 0.74, blue: 0.86),
        sand: Color(red: 0.86, green: 0.82, blue: 0.78),
        trayLight: Color(red: 0.36, green: 0.40, blue: 0.48),
        trayMid: Color(red: 0.24, green: 0.28, blue: 0.36),
        trayDeep: Color(red: 0.14, green: 0.16, blue: 0.24),
        lamp: Color(red: 0.98, green: 0.42, blue: 0.32),
        laneLine: Color(red: 0.95, green: 0.55, blue: 0.28)
    )

    static let superGarage = WorldTheme(
        id: 5,
        title: "Super Garage",
        tagline: "Festival lights",
        skyDeep: Color(red: 0.28, green: 0.34, blue: 0.58),
        skyMid: Color(red: 0.52, green: 0.42, blue: 0.68),
        skyLight: Color(red: 0.82, green: 0.70, blue: 0.88),
        sand: Color(red: 0.98, green: 0.88, blue: 0.70),
        trayLight: Color(red: 0.40, green: 0.38, blue: 0.48),
        trayMid: Color(red: 0.28, green: 0.26, blue: 0.36),
        trayDeep: Color(red: 0.18, green: 0.16, blue: 0.26),
        lamp: Color(red: 0.98, green: 0.55, blue: 0.72),
        laneLine: Color(red: 0.98, green: 0.86, blue: 0.40)
    )

    static let all: [WorldTheme] = [
        colorGarage, streetParade, classicLane, rescueYard, superGarage
    ]
}

extension GameLevel {
    static func worldID(for levelID: Int) -> Int {
        switch levelID {
        case 1...10: 1
        case 11...20: 2
        case 21...30: 3
        case 31...40: 4
        default: 5
        }
    }

    var theme: WorldTheme { WorldTheme.forWorld(world) }

    var missionLine: String { LevelStory.mission(for: id) }
    var winLine: String { LevelStory.winLine(for: id) }

    var mascot: PatternToken {
        switch world {
        case 1: PatternToken(toy: .raceCar, hue: .coral)
        case 2: PatternToken(toy: .bus, hue: .sunflower)
        case 3: PatternToken(toy: .modelT, hue: .apricot)
        case 4: PatternToken(toy: .fireTruck, hue: .mint)
        default: PatternToken(toy: .jeep, hue: .periwinkle)
        }
    }
}
