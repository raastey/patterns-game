# Pattern Path

Native SwiftUI pattern game for ages 5+ (iPhone + iPad). Kids park toys on a garage board. Each level changes **only color** or **only toy**, never both.

**App Store handoff:** [`docs/APP_STORE.md`](docs/APP_STORE.md)

## Worlds

1. **Color Garage** (1–10)  
2. **Street Parade** (11–20)  
3. **Classic Lane** (21–30)  
4. **Rescue Yard** (31–40)  
5. **Super Garage** (41–50)

## Features

- 50 clear repeating-unit levels + catalog validation tests  
- First-run coach, undo, stars, stickers, world themes  
- Grown-ups settings (sound, haptics, reset)  
- Soft CC0 UI SFX, Kenney / OpenGameArt CC0 vehicles  
- Privacy manifest: no tracking; progress on-device only  

## Requirements

- Xcode 16+  
- iOS / iPadOS 18+  
- Apple team `P3UCBA6NAQ` (already set in `project.yml`)

## Run

```bash
cd patterns-game
xcodegen generate
open PatternPath.xcodeproj
```

Verify:

```bash
./scripts/verify.sh
```

## Licenses

- Vehicles: `PatternPath/Resources/LICENSE-KENNEY-ASSETS.txt`  
- Audio: `PatternPath/Resources/Sounds/LICENSE-AUDIO-UISFX.txt`
