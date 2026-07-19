import Foundation

struct GarageSticker: Identifiable, Hashable {
    let milestone: Int
    let toy: ToyKind
    let hue: TokenHue
    let label: String

    var id: Int { milestone }

    var token: PatternToken { PatternToken(toy: toy, hue: hue) }
}

enum StickerCatalog {
    static let all: [GarageSticker] = [
        GarageSticker(milestone: 5, toy: .raceCar, hue: .coral, label: "Race Champ"),
        GarageSticker(milestone: 10, toy: .modelT, hue: .sunflower, label: "Classic Key"),
        GarageSticker(milestone: 15, toy: .bus, hue: .periwinkle, label: "Parade Bus"),
        GarageSticker(milestone: 20, toy: .fireTruck, hue: .mint, label: "Rescue Star"),
        GarageSticker(milestone: 25, toy: .policeCar, hue: .teal, label: "Night Patrol"),
        GarageSticker(milestone: 30, toy: .topolino, hue: .apricot, label: "Lane Classic"),
        GarageSticker(milestone: 35, toy: .semiTruck, hue: .coral, label: "Yard Boss"),
        GarageSticker(milestone: 40, toy: .ambulance, hue: .sunflower, label: "Care Bay"),
        GarageSticker(milestone: 45, toy: .jeep, hue: .periwinkle, label: "Trail Scout"),
        GarageSticker(milestone: 50, toy: .classicSedan, hue: .mint, label: "Crown Garage")
    ]

    static func sticker(forMilestone milestone: Int) -> GarageSticker? {
        all.first { $0.milestone == milestone }
    }

    static func stickerUnlocked(byClearing levelID: Int) -> GarageSticker? {
        guard levelID > 0, levelID % 5 == 0 else { return nil }
        return sticker(forMilestone: levelID)
    }
}
