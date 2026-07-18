# Pattern Path

A native SwiftUI iPad game that teaches visual patterns for ages 5 and up.

## What it is

Kids complete colorful bead sequences along a wooden path. Forty unique levels unlock across five worlds. Each level changes **only color** or **only shape** (never both at once), which keeps the rule clear for ages 5+ and Level 1 autistic players.

1. **Color Path** (1–8) — same shape; watch the colors  
2. **Shape Path** (9–16) — same color; watch the shapes  
3. **Longer Colors** (17–24) — longer color walks, still one shape  
4. **Longer Shapes** (25–32) — longer shape walks, still one color  
5. **Big Patterns** (33–40) — longer fills; still single-attribute

Wrong taps gently shake with a soft undo sound. Clear a level for stars and the next unlock. Mute anytime with the speaker button.

## Sound

Calm UI SFX from [UI SFX](https://github.com/romainsimon/uisfx) (`organic` + soft undo), dedicated to the public domain under **CC0 1.0**. License copy: `PatternPath/Resources/Sounds/LICENSE-AUDIO-UISFX.txt`.

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
