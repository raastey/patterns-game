# Pattern Path

A native SwiftUI iPad game that teaches visual patterns for ages 5 and up.

## What it is

Kids park toys on a multi-row garage board — **34 open-source vehicles**, including classics (Model T, Topolino, classic sedan), street cars, buses, trucks, rescue, and more. Fifty unique levels. Each level changes **only color** or **only toy** (never both), which keeps the rule clear for ages 5+ and Level 1 autistic players.

1. **Color Garage** (1–10) — same toy; watch the colors  
2. **Toy Parade** (11–20) — same color; watch the toys  
3. **Color Missions** (21–30) — gaps, sandwiches, mirrors  
4. **Toy Missions** (31–40) — gaps, sandwiches, mirrors  
5. **Super Garage** (41–50) — bigger boards and finales

Wrong taps gently shake. Streaks celebrate “N in a row!” with arcade pop sounds. Mute with the speaker; tap the waveform for a haptic test (hold to toggle).

## Art

3D vehicles rendered from CC0 packs (Kenney Car/Space Kit, OpenGameArt vehicle packs, classic Model T / Topolino / W136). License note: `PatternPath/Resources/LICENSE-KENNEY-ASSETS.txt`.

## Sound

Soft UI SFX from [UI SFX](https://github.com/romainsimon/uisfx) (`soft` + `dreamy` + `zen` + `glass` packs), **CC0 1.0**. License: `PatternPath/Resources/Sounds/LICENSE-AUDIO-UISFX.txt`.

## Requirements

- Xcode 16+ (tested with Xcode 26)
- iPadOS 17+
- iPad Simulator or device

## Open and run

```bash
cd patterns-game
xcodegen generate
open PatternPath.xcodeproj
```

In Xcode, select an **iPad** simulator and press Run.

Or build from the terminal:

```bash
xcodegen generate
xcodebuild -scheme PatternPath -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' build
```

## Design

Premium Apple Arcade–style polish for iPad and iPhone (iOS 18+):

- MeshGradient mist atmosphere with slow ambient drift
- Vitreous glass beads with specular caps and contact shadows
- Smoked-oak path tray with frosted glass chrome (`.ultraThinMaterial`)
- SF Rounded type, Reduce Motion support
- Core Haptics choreography (rising correct pops, soft wrong nudge, star pops, celebration cascade); toggle with the hand icon
- Adaptive layout for compact (iPhone) and regular (iPad) size classes

## Progress

Stars and unlock progress save in `UserDefaults` on device.
