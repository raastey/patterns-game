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
        let race = ToyKind.raceCar
        let sedan = ToyKind.sedan
        let sportSedan = ToyKind.sportsSedan
        let hatch = ToyKind.hatchback
        let coupe = ToyKind.coupe
        let compact = ToyKind.compactCar
        let city = ToyKind.cityCar
        let wagon = ToyKind.wagon
        let taxi = ToyKind.taxi
        let suv = ToyKind.suv
        let lux = ToyKind.luxurySUV
        let future = ToyKind.futureRacer
        let kart = ToyKind.goKart
        let modelT = ToyKind.modelT
        let topolino = ToyKind.topolino
        let classic = ToyKind.classicSedan
        let jeep = ToyKind.jeep
        let pickup = ToyKind.pickup
        let bus = ToyKind.bus
        let fire = ToyKind.fireTruck
        let police = ToyKind.policeCar
        let ambo = ToyKind.ambulance
        let dump = ToyKind.dumpTruck
        let garbage = ToyKind.garbageTruck
        let box = ToyKind.boxTruck
        let tanker = ToyKind.tankerTruck
        let semi = ToyKind.semiTruck
        let carrier = ToyKind.carCarrier
        let delivery = ToyKind.delivery
        let tractor = ToyKind.tractor
        let loader = ToyKind.loader
        let robot = ToyKind.robot
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
                       toy: race, hues: [coral, teal, coral, teal, coral, teal],
                       blankMask: [F, F, F, F, F, B], choiceHues: [teal, sun]),

            colorLevel(2, title: "Model T Colors", subtitle: "A classic takes the stage",
                       toy: modelT, hues: [sun, peri, sun, peri, sun, peri],
                       blankMask: [F, F, F, F, F, B], choiceHues: [peri, mint, coral]),

            colorLevel(3, title: "Bus Pairs", subtitle: "Two the same, then switch",
                       toy: bus, hues: [mint, mint, coral, coral, mint, mint, coral, coral],
                       blankMask: [F, F, F, F, F, F, B, B], choiceHues: [coral, mint, sun]),

            colorLevel(4, title: "Topolino Rainbow", subtitle: "Three colors take turns",
                       toy: topolino, hues: [teal, apri, peri, teal, apri, peri],
                       blankMask: [F, F, F, F, F, B], choiceHues: [peri, sun, mint]),

            colorLevel(5, title: "Jeep Gap", subtitle: "Which color belongs here?",
                       toy: jeep, hues: [apri, teal, apri, teal, apri, teal],
                       blankMask: [F, F, F, B, F, F], choiceHues: [teal, mint, peri]),

            colorLevel(6, title: "Ambulance Pairs", subtitle: "A pair, then a new color",
                       toy: ambo, hues: [mint, mint, coral, mint, mint, coral],
                       blankMask: [F, F, F, F, F, B], choiceHues: [coral, mint, teal]),

            colorLevel(7, title: "Pickup Bounce", subtitle: "Find the missing bounce",
                       toy: pickup, hues: [coral, sun, coral, sun, coral, sun, coral, sun, coral],
                       blankMask: [F, F, F, F, B, F, F, F, F], choiceHues: [coral, sun, teal],
                       columns: 3),

            colorLevel(8, title: "Classic Wave", subtitle: "Finish both colors",
                       toy: classic, hues: [apri, peri, apri, peri, apri, peri],
                       blankMask: [F, F, F, F, B, B], choiceHues: [apri, peri, sun, mint]),

            colorLevel(9, title: "Coupe Climb", subtitle: "Climb the warm colors",
                       toy: coupe, hues: [coral, apri, sun, coral, apri, sun],
                       blankMask: [F, F, B, F, B, F], choiceHues: [apri, sun, mint, peri]),

            colorLevel(10, title: "Fire Truck Cool", subtitle: "Two cool colors to park",
                       toy: fire, hues: [mint, teal, peri, mint, teal, peri],
                       blankMask: [F, F, F, B, F, B], choiceHues: [peri, mint, coral, sun]),

            // MARK: World 2 — Toy Parade
            toyLevel(11, title: "Street Parade", subtitle: "What vehicle comes next?",
                     hue: peri, toys: [race, taxi, race, taxi, race, taxi],
                     blankMask: [F, F, F, F, F, B], choiceToys: [taxi, bus, jeep]),

            toyLevel(12, title: "Classic Friends", subtitle: "Model T, Topolino, classic…",
                     hue: sun, toys: [modelT, topolino, classic, modelT, topolino, classic],
                     blankMask: [F, F, F, F, F, B], choiceToys: [classic, jeep, taxi, bus]),

            toyLevel(13, title: "Twin Trucks", subtitle: "Two alike, then switch",
                     hue: mint, toys: [dump, dump, box, box, dump, dump, box, box],
                     blankMask: [F, F, F, F, F, F, B, B], choiceToys: [box, dump, tanker, semi]),

            toyLevel(14, title: "Rescue Dance", subtitle: "Find the missing rescue",
                     hue: coral, toys: [fire, police, fire, police, fire, police],
                     blankMask: [F, F, F, B, F, F], choiceToys: [police, ambo, jeep, taxi]),

            toyLevel(15, title: "Yard Gap", subtitle: "Two spots to fill",
                     hue: teal, toys: [loader, carrier, loader, carrier, loader, carrier],
                     blankMask: [F, F, B, F, F, B], choiceToys: [carrier, loader, tractor, bus]),

            toyLevel(16, title: "City Hop", subtitle: "One taxi, then two buses",
                     hue: apri, toys: [taxi, bus, bus, taxi, bus, bus],
                     blankMask: [F, B, F, F, B, F], choiceToys: [bus, taxi, city, wagon]),

            toyLevel(17, title: "Sport Pair", subtitle: "Pairs with a twist",
                     hue: peri, toys: [sportSedan, sportSedan, hatch, sportSedan, sportSedan, hatch, sportSedan, sportSedan],
                     blankMask: [F, F, F, F, B, F, B, F], choiceToys: [hatch, sportSedan, coupe, race]),

            toyLevel(18, title: "Work Convoy", subtitle: "ABC across the yard",
                     hue: sun, toys: [pickup, dump, garbage, pickup, dump, garbage],
                     blankMask: [F, F, F, B, F, B], choiceToys: [pickup, dump, garbage, tanker]),

            toyLevel(19, title: "Vehicle Quartet", subtitle: "Four vehicles — find two",
                     hue: mint, toys: [bus, fire, jeep, kart, bus, fire, jeep, kart],
                     blankMask: [F, F, B, F, F, F, B, F], choiceToys: [jeep, kart, dump, rocket, fire]),

            toyLevel(20, title: "Ambulance Home", subtitle: "Repair both gaps",
                     hue: coral, toys: [ambo, taxi, fire, ambo, taxi, fire],
                     blankMask: [F, B, F, F, B, F], choiceToys: [ambo, taxi, fire, police, bus]),

            // MARK: World 3 — Color Missions
            colorLevel(21, title: "Long Future Run", subtitle: "Hold the AB rhythm",
                       toy: future, hues: [coral, teal, coral, teal, coral, teal, coral, teal],
                       blankMask: [F, F, B, F, F, B, F, F], choiceHues: [coral, teal, mint, sun]),

            colorLevel(22, title: "Skip Bus Color", subtitle: "Which color was skipped?",
                       toy: bus, hues: [sun, mint, peri, sun, mint, peri, sun, mint],
                       blankMask: [F, F, F, F, B, F, F, B], choiceHues: [mint, peri, sun, coral]),

            colorLevel(23, title: "Two Jeep Gaps", subtitle: "Gaps that are far apart",
                       toy: jeep, hues: [apri, teal, apri, teal, apri, teal, apri, teal],
                       blankMask: [F, B, F, F, F, B, F, F], choiceHues: [apri, teal, peri, mint]),

            colorLevel(24, title: "Semi Sandwich", subtitle: "What sits in the middle?",
                       toy: semi, hues: [coral, mint, mint, coral, mint, mint, coral, mint, mint],
                       blankMask: [F, B, F, F, B, F, F, F, B], choiceHues: [mint, coral, sun, peri],
                       columns: 3),

            colorLevel(25, title: "Police Pair Bridge", subtitle: "Pairs across the bridge",
                       toy: police, hues: [coral, coral, mint, mint, coral, coral, mint, mint],
                       blankMask: [F, B, F, F, F, B, F, F], choiceHues: [mint, coral, sun, teal]),

            colorLevel(26, title: "Wagon ABC", subtitle: "Three colors — two blanks",
                       toy: wagon, hues: [peri, sun, mint, peri, sun, mint, peri, sun, mint],
                       blankMask: [F, F, B, F, B, F, F, F, F], choiceHues: [peri, sun, mint, coral],
                       columns: 3),

            colorLevel(27, title: "Mirror Lux SUVs", subtitle: "It rolls out, then back",
                       toy: lux, hues: [teal, coral, sun, peri, peri, sun, coral, teal],
                       blankMask: [F, F, F, B, B, F, F, F], choiceHues: [coral, teal, mint, sun, peri],
                       columns: 4),

            colorLevel(28, title: "Tanker Repair", subtitle: "Three broken spots",
                       toy: tanker, hues: [mint, apri, mint, apri, mint, apri, mint, apri],
                       blankMask: [F, B, F, F, B, F, F, B], choiceHues: [mint, apri, coral, sun]),

            colorLevel(29, title: "Festival Compacts", subtitle: "Four colors in the parade",
                       toy: compact, hues: [coral, sun, teal, peri, coral, sun, teal, peri],
                       blankMask: [F, F, B, F, F, B, F, B], choiceHues: [teal, peri, sun, mint, apri]),

            colorLevel(30, title: "Rainbow Model T", subtitle: "Every color — find three",
                       toy: modelT, hues: [coral, apri, sun, mint, teal, peri, coral, apri],
                       blankMask: [F, F, B, F, B, F, F, B], choiceHues: [mint, teal, sun, peri, coral, apri],
                       columns: 4),

            // MARK: World 4 — Toy Missions
            toyLevel(31, title: "Long Street Walk", subtitle: "Keep the AB rhythm",
                     hue: teal, toys: [city, taxi, city, taxi, city, taxi, city, taxi],
                     blankMask: [F, F, B, F, F, B, F, F], choiceToys: [city, taxi, bus, wagon]),

            toyLevel(32, title: "Skip Rescue", subtitle: "Which vehicle was skipped?",
                     hue: mint, toys: [fire, police, ambo, fire, police, ambo, fire, police],
                     blankMask: [F, F, F, F, B, F, F, B], choiceToys: [police, ambo, bus, jeep]),

            toyLevel(33, title: "Two Work Gaps", subtitle: "Gaps far apart",
                     hue: coral, toys: [box, tanker, box, tanker, box, tanker, box, tanker],
                     blankMask: [F, B, F, F, F, B, F, F], choiceToys: [box, tanker, semi, dump]),

            toyLevel(34, title: "Classic Sandwich", subtitle: "What sits between?",
                     hue: sun, toys: [modelT, topolino, topolino, modelT, topolino, topolino, modelT, topolino, topolino],
                     blankMask: [F, B, F, F, B, F, F, F, B], choiceToys: [topolino, modelT, classic, jeep],
                     columns: 3),

            toyLevel(35, title: "Pair Convoy", subtitle: "Two alike — three blanks",
                     hue: peri, toys: [semi, semi, carrier, carrier, semi, semi, carrier, carrier],
                     blankMask: [F, B, F, F, F, B, F, B], choiceToys: [carrier, semi, dump, box]),

            toyLevel(36, title: "Garage ABC", subtitle: "Three vehicles — two blanks",
                     hue: apri, toys: [loader, bus, kart, loader, bus, kart, loader, bus, kart],
                     blankMask: [F, F, B, F, B, F, F, F, F], choiceToys: [loader, bus, kart, fire, jeep],
                     columns: 3),

            toyLevel(37, title: "Mirror Garage", subtitle: "Out and back — two spots",
                     hue: mint, toys: [fire, pickup, carrier, lux, lux, carrier, pickup, fire],
                     blankMask: [F, F, F, B, B, F, F, F], choiceToys: [pickup, fire, jeep, carrier, lux],
                     columns: 4),

            toyLevel(38, title: "Busy Yard", subtitle: "Four vehicles — three blanks",
                     hue: coral, toys: [bus, fire, jeep, garbage, bus, fire, jeep, garbage],
                     blankMask: [F, F, B, F, F, B, F, B], choiceToys: [jeep, garbage, fire, tractor, rocket]),

            toyLevel(39, title: "Sport Trail", subtitle: "AAB AAB with holes",
                     hue: sun, toys: [sportSedan, sportSedan, coupe, sportSedan, sportSedan, coupe, sportSedan, sportSedan, coupe],
                     blankMask: [F, B, F, F, B, F, F, F, B], choiceToys: [sportSedan, coupe, hatch, race],
                     columns: 3),

            toyLevel(40, title: "Broken Convoy", subtitle: "Four repairs in the yard",
                     hue: teal, toys: [dump, delivery, ambo, dump, delivery, ambo, dump, delivery, ambo],
                     blankMask: [F, B, F, F, B, F, F, B, B], choiceToys: [dump, delivery, ambo, fire, police],
                     columns: 3),

            // MARK: World 5 — Super Garage
            colorLevel(41, title: "Mega Kart Bridge", subtitle: "ABC — park three",
                       toy: kart, hues: [coral, teal, sun, coral, teal, sun, coral, teal, sun],
                       blankMask: [F, F, B, F, B, F, F, F, B], choiceHues: [coral, teal, sun, mint, peri],
                       columns: 3),

            toyLevel(42, title: "Mega Fleet Bridge", subtitle: "ABC — park three",
                     hue: peri, toys: [bus, fire, modelT, bus, fire, modelT, bus, fire, modelT],
                     blankMask: [F, B, F, F, F, B, F, B, F], choiceToys: [bus, fire, modelT, jeep, ambo],
                     columns: 3),

            colorLevel(43, title: "Pickup Chorus", subtitle: "Every other color",
                       toy: pickup, hues: [mint, peri, mint, peri, mint, peri, mint, peri, mint, peri, mint, peri],
                       blankMask: [F, B, F, B, F, B, F, F, F, B, F, F], choiceHues: [peri, mint, coral, sun],
                       columns: 4),

            toyLevel(44, title: "Rescue Chorus", subtitle: "Every other vehicle",
                     hue: sun, toys: [fire, police, ambo, fire, police, ambo, fire, police, ambo, fire, police, ambo],
                     blankMask: [F, B, F, F, B, F, F, B, F, F, B, F], choiceToys: [police, fire, ambo, dump, bus],
                     columns: 4),

            colorLevel(45, title: "Bus Pulse", subtitle: "Pairs — four blanks",
                       toy: bus, hues: [coral, coral, teal, teal, coral, coral, teal, teal, coral, coral, teal, teal],
                       blankMask: [F, B, F, F, F, B, F, B, F, F, F, B], choiceHues: [coral, teal, sun, mint],
                       columns: 4),

            toyLevel(46, title: "Work Pulse", subtitle: "Pairs — four blanks",
                     hue: mint, toys: [semi, semi, tanker, tanker, semi, semi, tanker, tanker, semi, semi, tanker, tanker],
                     blankMask: [F, F, F, B, F, B, F, F, F, B, F, B], choiceToys: [semi, tanker, box, dump],
                     columns: 4),

            colorLevel(47, title: "Topolino Ribbon", subtitle: "Four colors — three gaps",
                       toy: topolino, hues: [coral, mint, peri, sun, coral, mint, peri, sun, coral, mint, peri, sun],
                       blankMask: [F, F, B, F, F, B, F, F, F, F, B, F], choiceHues: [peri, sun, mint, apri, teal],
                       columns: 4),

            toyLevel(48, title: "Yard Ribbon", subtitle: "Four vehicles — three gaps",
                     hue: apri, toys: [bus, jeep, dump, tractor, bus, jeep, dump, tractor, bus, jeep, dump, tractor],
                     blankMask: [F, B, F, F, F, F, B, F, F, B, F, F], choiceToys: [dump, tractor, jeep, police, rocket],
                     columns: 4),

            colorLevel(49, title: "Crown Classics", subtitle: "Six colors — four parks",
                       toy: classic, hues: [coral, apri, sun, mint, teal, peri, coral, apri, sun, mint, teal, peri],
                       blankMask: [F, F, B, F, B, F, F, B, F, F, B, F], choiceHues: [mint, teal, peri, sun, apri, coral],
                       columns: 4),

            toyLevel(50, title: "Crown Finale", subtitle: "The whole garage — four parks",
                     hue: mint, toys: [modelT, bus, fire, jeep, dump, semi, tractor, rocket, taxi, lux, ambo, topolino],
                     blankMask: [F, F, B, F, F, B, F, F, F, B, F, B], choiceToys: [fire, semi, lux, topolino, dump, tractor, jeep],
                     columns: 4)
        ]
    }
}
