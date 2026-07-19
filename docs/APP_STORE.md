# Pattern Path — App Store handoff

Engineering for **v1.0.0** is closed. Human UAT, screenshots, and App Store Connect are yours.

## Binary

| Field | Value |
|-------|-------|
| Bundle ID | `fun.raastey.patternpath` |
| Display name | Pattern Path |
| Version / build | `1.0.0` / `1` |
| Team | `P3UCBA6NAQ` |
| Category | Education |
| Devices | iPhone + iPad |
| Min OS | iOS / iPadOS 18.0 |
| Model | Free or paid (your call). No IAP, no ads, no account |
| Privacy | Data Not Collected. Local `UserDefaults` only |
| Encryption | Exempt (`ITSAppUsesNonExemptEncryption = false`) |
| Privacy manifest | `PatternPath/PrivacyInfo.xcprivacy` |

## What is in the app

- 50 single-attribute pattern levels (color XOR toy)
- First-run coach on level 1
- Undo last placement
- Stars, sequential unlock, stickers every 5 levels
- Five world themes + garage bay fill
- Grown-ups settings: sound, haptics, reset progress
- Mute + haptics persist
- Reduce Motion respected
- CC0 art + CC0 UI SFX (licenses in `PatternPath/Resources/`)

## UAT checklist (do this before submit)

1. Fresh install → coach on level 1 → first park → coach goes away
2. Wrong tap shakes gently; **Back** undoes last park
3. Clear a level with mistakes → “Try for 3 Stars” appears
4. Clear level 5 → sticker unlock banner
5. Grown-ups → toggle sound/haptics → relaunch → still set
6. Grown-ups → Reset → back to level 1, coach returns
7. Portrait + landscape on iPad; portrait on iPhone
8. Mute works; Reduce Motion on/off
9. `./scripts/verify.sh` passes

## Bundle (IPA)

Already exported and distribution-signed:

- `build/export/PatternPath.ipa` (also copied to `~/Desktop/PatternPath-1.0.0.ipa`)
- Bundle ID: `fun.raastey.patternpath` (registered in Developer portal)
- Signing: Apple Distribution · Team `P3UCBA6NAQ`
- Version / build: `1.0.0` / `1`

### One-time App Store Connect step (browser)

API keys cannot create apps. Create the record once:

1. Open [App Store Connect → My Apps → +](https://appstoreconnect.apple.com/apps)
2. **New App**
3. Platforms: iOS  
   Name: Pattern Path  
   Primary language: English (U.S.)  
   Bundle ID: `fun.raastey.patternpath`  
   SKU: `fun.raastey.patternpath`  
   User Access: Full Access
4. Create

Then either:

- Drop `~/Desktop/PatternPath-1.0.0.ipa` into **Transporter**, or
- Ask the agent: `./scripts/testflight-upload.sh --upload-only`

### Re-export / re-upload later

```bash
cd patterns-game
./scripts/testflight-upload.sh              # archive + export + upload
./scripts/testflight-upload.sh --upload-only
```

Or in Xcode: Any iOS Device → Product → Archive → Distribute → App Store Connect.

## App Store Connect copy (paste)

**Subtitle (30):** Park toys. Find the pattern.

**Promotional text (170):** Fifty calm garage missions. One thing to watch at a time: color or toy, never both. Built for ages 5+ and Level 1 autistic players.

**Description:**

Pattern Path is a calm toy-garage pattern game for kids ages 5 and up.

Park buses, classics, rescue trucks, and more. Each level asks you to notice only one thing: the colors, or the toys. Never both. That keeps the rule clear and friendly for Level 1 autistic players.

• 50 unique levels across five garage worlds  
• Soft sounds, gentle haptics, and a cozy win celebration  
• Stickers to unlock as you park more vehicles  
• Undo if you change your mind  
• Grown-ups settings to mute, turn off haptics, or reset progress  

No ads. No accounts. No tracking. Progress stays on this device.

Art and sound are open-source CC0 assets (see in-app licenses).

**Keywords (100):** pattern,kids,autism,learning,toys,garage,colors,preschool,puzzle,calm

**Support URL:** https://raastey.com (or your support page)

**Marketing URL:** optional

**Age rating:** 4+  
Content: no unrestricted web, no violence, no gambling, etc. (all None / No)

**Privacy Nutrition Labels:** Data Not Collected

**Review notes:**

Offline education game. No account, no IAP required, no third-party analytics. Patterns use a single attribute per level (color or vehicle). Grown-ups screen (person icon on home) can reset progress. First launch coaches level 1.

## Screenshots needed

Capture from Simulator or device (light mode):

1. Home with garage bays  
2. Play board mid-level (portrait iPad + iPhone 6.7")  
3. Choice shelf / coaching moment  
4. Celebration with stars  
5. Sticker garage or level map  

Minimum: iPhone 6.7" and iPad 13" sets for current ASC requirements.

## Regen project

```bash
xcodegen generate
open PatternPath.xcodeproj
```
