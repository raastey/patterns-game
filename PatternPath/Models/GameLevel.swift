import Foundation

enum PatternFocus: String, Hashable {
    case color
    case toy

    var prompt: String {
        switch self {
        case .color: "Look at the colors"
        case .toy: "Look at the toys"
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
    let columns: Int

    var blankCount: Int { slots.filter(\.isBlank).count }
    var rowCount: Int {
        Int(ceil(Double(slots.count) / Double(max(columns, 1))))
    }

    var world: Int {
        switch id {
        case 1...10: 1
        case 11...20: 2
        case 21...30: 3
        case 31...40: 4
        default: 5
        }
    }

    var worldTitle: String {
        switch world {
        case 1: "Color Garage"
        case 2: "Toy Parade"
        case 3: "Color Missions"
        case 4: "Toy Missions"
        default: "Super Garage"
        }
    }
}

enum LevelCatalog {
    static let totalCount = 50
    static let all: [GameLevel] = makeLevels()

    static func level(id: Int) -> GameLevel? {
        all.first { $0.id == id }
    }

    static func boardColumns(forSlotCount count: Int) -> Int {
        switch count {
        case 0...2: return max(count, 1)
        case 3: return 3
        case 4: return 2
        case 5, 6: return 3
        case 7, 8: return 4
        case 9: return 3
        default: return 4
        }
    }

    private static func t(_ toy: ToyKind, _ hue: TokenHue) -> PatternToken {
        PatternToken(toy: toy, hue: hue)
    }

    private static func level(
        _ id: Int,
        title: String,
        subtitle: String,
        focus: PatternFocus,
        sequence: [PatternToken?],
        answers: [PatternToken],
        choices: [PatternToken],
        stars: Int = 3,
        columns: Int? = nil
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
            starsToEarn: stars,
            columns: columns ?? boardColumns(forSlotCount: slots.count)
        )
    }

    /// Same toy, different colors.
    private static func colorLevel(
        _ id: Int,
        title: String,
        subtitle: String,
        toy: ToyKind,
        hues: [TokenHue],
        blankMask: [Bool],
        choiceHues: [TokenHue],
        columns: Int? = nil
    ) -> GameLevel {
        precondition(hues.count == blankMask.count)
        var answers: [PatternToken] = []
        let sequence: [PatternToken?] = zip(hues, blankMask).map { hue, isBlank in
            let token = t(toy, hue)
            if isBlank {
                answers.append(token)
                return nil
            }
            return token
        }
        return level(
            id, title: title, subtitle: subtitle, focus: .color,
            sequence: sequence, answers: answers,
            choices: choiceHues.map { t(toy, $0) },
            columns: columns
        )
    }

    /// Same color, different toys.
    private static func toyLevel(
        _ id: Int,
        title: String,
        subtitle: String,
        hue: TokenHue,
        toys: [ToyKind],
        blankMask: [Bool],
        choiceToys: [ToyKind],
        columns: Int? = nil
    ) -> GameLevel {
        precondition(toys.count == blankMask.count)
        var answers: [PatternToken] = []
        let sequence: [PatternToken?] = zip(toys, blankMask).map { toy, isBlank in
            let token = t(toy, hue)
            if isBlank {
                answers.append(token)
                return nil
            }
            return token
        }
        return level(
            id, title: title, subtitle: subtitle, focus: .toy,
            sequence: sequence, answers: answers,
            choices: choiceToys.map { t($0, hue) },
            columns: columns
        )
    }

    private static func makeLevels() -> [GameLevel] {
        let car = ToyKind.raceCar
        let fire = ToyKind.fireTruck
        let police = ToyKind.policeCar
        let dump = ToyKind.dumpTruck
        let carrier = ToyKind.carCarrier
        let robot = ToyKind.robot
        let ambo = ToyKind.ambulance
        let rocket = ToyKind.rocket

        let coral = TokenHue.coral
        let teal = TokenHue.teal
        let sun = TokenHue.sunflower
        let peri = TokenHue.periwinkle
        let mint = TokenHue.mint
        let apri = TokenHue.apricot

        let F = false
        let B = true

        return [
            // MARK: World 1 — Color Garage
            colorLevel(1, title: "Race Car Rally", subtitle: "What color comes next?",
                       toy: car, hues: [coral, teal, coral, teal, coral, teal],
                       blankMask: [F, F, F, F, F, B], choiceHues: [teal, sun]),

            colorLevel(2, title: "Fire Truck Colors", subtitle: "Keep the colors rolling",
                       toy: fire, hues: [coral, sun, coral, sun, coral, sun],
                       blankMask: [F, F, F, F, F, B], choiceHues: [sun, mint, peri]),

            colorLevel(3, title: "Police Pairs", subtitle: "Two the same, then switch",
                       toy: police, hues: [peri, peri, teal, teal, peri, peri, teal, teal],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [teal, peri, sun]),

            colorLevel(4, title: "Robot Rainbow", subtitle: "Three colors take turns",
                       toy: robot, hues: [mint, peri, coral, mint, peri, coral],
                       blankMask: [F, F, F, F, F, B], choiceHues: [coral, sun, mint]),

            colorLevel(5, title: "Dump Truck Gap", subtitle: "Which color belongs here?",
                       toy: dump, hues: [apri, teal, apri, teal, apri, teal],
                       blankMask: [F, F, F, B, F, F], choiceHues: [teal, mint, peri]),

            colorLevel(6, title: "Ambulance Pairs", subtitle: "A pair, then a new color",
                       toy: ambo, hues: [mint, mint, coral, mint, mint, coral],
                       blankMask: [F, F, F, F, F, B], choiceHues: [coral, mint, teal]),

            colorLevel(7, title: "Rocket Bounce", subtitle: "Out and back again",
                       toy: rocket, hues: [coral, teal, coral, teal, coral, teal, coral, teal, coral],
                       blankMask: [F, F, F, F, B, F, F, F, F], choiceHues: [coral, teal, sun],
                       columns: 3),

            colorLevel(8, title: "Carrier Wave", subtitle: "Finish both colors",
                       toy: carrier, hues: [apri, peri, apri, peri, apri, peri],
                       blankMask: [F, F, F, F, B, B], choiceHues: [apri, peri, sun]),

            colorLevel(9, title: "Warm Race Cars", subtitle: "Climb the warm colors",
                       toy: car, hues: [coral, apri, sun, coral, apri, sun],
                       blankMask: [F, F, F, F, B, B], choiceHues: [apri, sun, mint]),

            colorLevel(10, title: "Cool Fire Trucks", subtitle: "Cool colors rolling by",
                       toy: fire, hues: [mint, teal, peri, mint, teal, peri],
                       blankMask: [F, F, F, F, F, B], choiceHues: [peri, coral, mint]),

            // MARK: World 2 — Toy Parade
            toyLevel(11, title: "Car Fire Parade", subtitle: "What toy comes next?",
                     hue: peri, toys: [car, fire, car, fire, car, fire],
                     blankMask: [F, F, F, F, F, B], choiceToys: [fire, robot, dump]),

            toyLevel(12, title: "Three Toy Friends", subtitle: "Car, robot, truck…",
                     hue: sun, toys: [car, robot, dump, car, robot, dump],
                     blankMask: [F, F, F, F, F, B], choiceToys: [dump, police, rocket]),

            toyLevel(13, title: "Twin Toys", subtitle: "Two alike, then switch",
                     hue: mint, toys: [police, police, ambo, ambo, police, police, ambo, ambo],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [ambo, police, car]),

            toyLevel(14, title: "Rescue Dance", subtitle: "Fire, police, fire…",
                     hue: coral, toys: [fire, police, fire, police, fire, police],
                     blankMask: [F, F, F, F, F, B], choiceToys: [police, rocket, dump]),

            toyLevel(15, title: "Garage Gap", subtitle: "Which toy fits?",
                     hue: teal, toys: [dump, carrier, dump, carrier, dump, carrier],
                     blankMask: [F, F, F, B, F, F], choiceToys: [carrier, car, robot]),

            toyLevel(16, title: "Robot Hop", subtitle: "One car, then two robots",
                     hue: apri, toys: [car, robot, robot, car, robot, robot],
                     blankMask: [F, F, F, F, B, B], choiceToys: [robot, car, fire]),

            toyLevel(17, title: "Rocket Pair", subtitle: "Two rockets, then a car",
                     hue: peri, toys: [rocket, rocket, car, rocket, rocket, car],
                     blankMask: [F, F, F, F, F, B], choiceToys: [car, rocket, dump]),

            toyLevel(18, title: "Carrier Convoy", subtitle: "Finish the convoy",
                     hue: sun, toys: [carrier, dump, carrier, dump, carrier, dump],
                     blankMask: [F, F, F, F, B, B], choiceToys: [carrier, dump, ambo]),

            toyLevel(19, title: "Toy Quartet", subtitle: "Four toys, then again",
                     hue: mint, toys: [car, fire, police, robot, car, fire, police, robot],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [police, robot, dump, rocket]),

            toyLevel(20, title: "Ambulance Home", subtitle: "Find the ambulance",
                     hue: coral, toys: [ambo, car, ambo, car, ambo, car],
                     blankMask: [F, F, F, F, B, F], choiceToys: [ambo, fire, police]),

            // MARK: World 3 — Color Missions
            colorLevel(21, title: "Long Car Run", subtitle: "A longer color race",
                       toy: car, hues: [coral, teal, coral, teal, coral, teal, coral, teal],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [coral, teal, mint]),

            colorLevel(22, title: "Skip Fire Color", subtitle: "Which color was skipped?",
                       toy: fire, hues: [sun, mint, peri, sun, mint, peri],
                       blankMask: [F, F, F, F, B, F], choiceHues: [mint, sun, coral]),

            colorLevel(23, title: "Two Police Gaps", subtitle: "Fill both color gaps",
                       toy: police, hues: [apri, teal, apri, teal, apri, teal],
                       blankMask: [F, F, B, F, F, B], choiceHues: [apri, teal, peri]),

            colorLevel(24, title: "Robot Sandwich", subtitle: "What color sits between?",
                       toy: robot, hues: [coral, mint, mint, coral, mint, mint, coral, mint, mint],
                       blankMask: [F, F, B, F, F, B, F, F, F], choiceHues: [mint, coral, sun],
                       columns: 3),

            colorLevel(25, title: "Dump Pair Bridge", subtitle: "Pairs across the bridge",
                       toy: dump, hues: [coral, coral, mint, mint, coral, coral, mint, mint],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [mint, coral, sun]),

            colorLevel(26, title: "Rocket ABC", subtitle: "Three colors take turns",
                       toy: rocket, hues: [peri, sun, mint, peri, sun, mint, peri, sun],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [peri, sun, mint, coral]),

            colorLevel(27, title: "Mirror Ambulances", subtitle: "It rolls out, then back",
                       toy: ambo, hues: [teal, coral, sun, sun, coral, teal],
                       blankMask: [F, F, F, B, B, F], choiceHues: [coral, teal, mint, sun],
                       columns: 3),

            colorLevel(28, title: "Carrier Repair", subtitle: "Fix both broken spots",
                       toy: carrier, hues: [mint, apri, mint, apri, mint, apri, mint, apri],
                       blankMask: [F, F, B, F, F, B, F, F], choiceHues: [mint, apri, coral]),

            colorLevel(29, title: "Festival Cars", subtitle: "Four colors in the parade",
                       toy: car, hues: [coral, sun, teal, peri, coral, sun, teal, peri],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [teal, peri, mint, apri]),

            colorLevel(30, title: "Rainbow Robots", subtitle: "Every color takes a step",
                       toy: robot, hues: [coral, apri, sun, mint, teal, peri],
                       blankMask: [F, F, F, B, B, F], choiceHues: [mint, teal, coral, sun]),

            // MARK: World 4 — Toy Missions
            toyLevel(31, title: "Long Toy Walk", subtitle: "A longer toy parade",
                     hue: teal, toys: [car, fire, car, fire, car, fire, car, fire],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [car, fire, robot]),

            toyLevel(32, title: "Skip Rescue", subtitle: "Which toy was skipped?",
                     hue: mint, toys: [fire, police, ambo, fire, police, ambo],
                     blankMask: [F, F, F, F, B, F], choiceToys: [police, car, dump]),

            toyLevel(33, title: "Two Toy Gaps", subtitle: "Fill both toy gaps",
                     hue: coral, toys: [dump, carrier, dump, carrier, dump, carrier],
                     blankMask: [F, F, B, F, F, B], choiceToys: [dump, carrier, rocket]),

            toyLevel(34, title: "Toy Sandwich", subtitle: "What sits between?",
                     hue: sun, toys: [robot, car, car, robot, car, car, robot, car, car],
                     blankMask: [F, F, B, F, F, B, F, F, F], choiceToys: [car, robot, fire],
                     columns: 3),

            toyLevel(35, title: "Pair Convoy", subtitle: "Two alike, then switch",
                     hue: peri, toys: [police, police, ambo, ambo, police, police, ambo, ambo],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [ambo, police, dump]),

            toyLevel(36, title: "Toy ABC", subtitle: "Three toys take turns",
                     hue: apri, toys: [car, rocket, robot, car, rocket, robot, car, rocket],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [car, rocket, robot, fire]),

            toyLevel(37, title: "Mirror Garage", subtitle: "It rolls out, then back",
                     hue: mint, toys: [fire, dump, carrier, carrier, dump, fire],
                     blankMask: [F, F, F, B, B, F], choiceToys: [dump, fire, car, carrier],
                     columns: 3),

            toyLevel(38, title: "Busy Yard", subtitle: "Grow the toy yard",
                     hue: coral, toys: [car, fire, police, dump, car, fire, police, dump],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [police, dump, robot, rocket]),

            toyLevel(39, title: "Rocket Trail", subtitle: "Rockets and robots only",
                     hue: sun, toys: [rocket, robot, rocket, robot, rocket, robot, rocket, robot],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [rocket, robot, car]),

            toyLevel(40, title: "Broken Convoy", subtitle: "Repair the trucks",
                     hue: teal, toys: [dump, carrier, dump, carrier, dump, carrier, dump, carrier],
                     blankMask: [F, F, B, F, F, B, F, F], choiceToys: [dump, carrier, fire]),

            // MARK: World 5 — Super Garage
            colorLevel(41, title: "Mega Car Bridge", subtitle: "Three colors to park",
                       toy: car, hues: [coral, teal, sun, coral, teal, sun, coral, teal, sun],
                       blankMask: [F, F, F, F, F, F, B, B, B], choiceHues: [coral, teal, sun, mint],
                       columns: 3),

            toyLevel(42, title: "Mega Toy Bridge", subtitle: "Three toys to park",
                     hue: peri, toys: [car, fire, robot, car, fire, robot, car, fire, robot],
                     blankMask: [F, F, F, F, F, F, B, B, B], choiceToys: [car, fire, robot, dump],
                     columns: 3),

            colorLevel(43, title: "Fire Chorus", subtitle: "Find every missing color",
                       toy: fire, hues: [mint, peri, mint, peri, mint, peri, mint, peri],
                       blankMask: [F, B, F, B, F, B, F, F], choiceHues: [peri, mint, coral]),

            toyLevel(44, title: "Rescue Chorus", subtitle: "Find every missing toy",
                     hue: sun, toys: [fire, police, fire, police, fire, police, fire, police],
                     blankMask: [F, B, F, B, F, B, F, F], choiceToys: [police, fire, ambo]),

            colorLevel(45, title: "Robot Pulse", subtitle: "Two and two, again",
                       toy: robot, hues: [coral, coral, teal, teal, coral, coral, teal, teal],
                       blankMask: [F, F, F, F, B, B, B, B], choiceHues: [coral, teal, sun]),

            toyLevel(46, title: "Carrier Pulse", subtitle: "Two and two, again",
                     hue: mint, toys: [carrier, carrier, dump, dump, carrier, carrier, dump, dump],
                     blankMask: [F, F, F, F, B, B, B, B], choiceToys: [carrier, dump, car]),

            colorLevel(47, title: "Police Ribbon", subtitle: "A long soft color song",
                       toy: police, hues: [coral, mint, peri, sun, coral, mint, peri, sun],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [peri, sun, apri, teal]),

            toyLevel(48, title: "Yard Ribbon", subtitle: "A long soft toy song",
                     hue: apri, toys: [car, fire, dump, rocket, car, fire, dump, rocket],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [dump, rocket, police, robot]),

            colorLevel(49, title: "Crown Cars", subtitle: "The garage almost sings",
                       toy: car, hues: [coral, apri, sun, mint, teal, peri, coral, apri, sun, mint, teal, peri],
                       blankMask: [F, F, F, F, F, F, F, F, F, B, B, B], choiceHues: [mint, teal, peri, coral],
                       columns: 4),

            toyLevel(50, title: "Crown Finale", subtitle: "The whole garage sings",
                     hue: mint, toys: [car, fire, police, dump, carrier, robot, ambo, rocket, car, fire, police, dump],
                     blankMask: [F, F, F, F, F, F, F, F, F, B, B, B], choiceToys: [fire, police, dump, rocket],
                     columns: 4)
        ]
    }
}
