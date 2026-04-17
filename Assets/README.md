# HerdMaster Assets — Master Library

Drop your design assets here. They flow to two targets:

- `../HerdMasterPreview/Assets.xcassets/` — iOS app asset catalog (used by Xcode at build time)
- `../WebPreview/assets/` — HTML preview (used by browser for design fidelity checks)

## Folder Rules

### Logos/
The HerdMaster brand shield and wordmark in every format the app needs.

Required files (once you have the final design):
- `herdmaster-logo.svg` — master vector, renders any size
- `herdmaster-logo@1x.png` — 96×112 baseline
- `herdmaster-logo@2x.png` — 192×224 retina
- `herdmaster-logo@3x.png` — 288×336 super-retina
- `herdmaster-wordmark.svg` — text-only variant for narrow contexts
- `herdmaster-icon-only.svg` — glyph without the shield frame

For the actual App Store app icon, use `../HerdMasterPreview/Assets.xcassets/AppIcon.appiconset/` — it needs exactly 1024×1024 (App Store) plus all the required intermediate sizes.

### Photos/
Real rabbit photos for placeholders and demos.

Current placeholders (all SVG rabbit silhouettes). When you get real photos:
- Aspect ratio: 1:1 (square) for avatar use
- Minimum resolution: 600×600 for 200pt circle avatars on iPhone Pro Max
- Format: JPEG for photos, PNG only if transparency matters
- Naming: `rabbit-<name-or-role>.jpg` (lowercase, hyphens)

Examples when real:
- `rabbit-barnaby.jpg` — matching the demo buck
- `rabbit-luna.jpg` — matching the demo doe
- `hero-onboarding.jpg` — full-bleed hero image for splash

### Icons/
Custom icons that SF Symbols doesn't cover. Use SF Symbols for everything possible — they scale cleanly and follow Apple HIG.

When you need a custom one:
- Format: SVG (vector always wins)
- Style: 2pt stroke, rounded caps, matches SF Symbols visual weight
- Size reference: drawn at 24×24 viewport, will render at any size
- Naming: `icon-<concept>.svg` (e.g. `icon-ear-tag.svg`)

### Illustrations/
Empty states, onboarding hero art, error screens. Larger format than icons.

- Format: SVG preferred, PNG if the illustration is a rendered/painted style
- Min size: 320×320 (for iPhone mini, it'll scale up cleanly)
- Naming: `illustration-<context>.svg` (e.g. `illustration-empty-herd.svg`)

## How to Add a New Asset

1. Drop the source file into the right subfolder here (`Assets/`)
2. Run `./sync-assets.sh` from project root (auto-copies to iOS + web)
3. In Swift: reference via `Image("rabbit-barnaby")` (asset catalog name)
4. In HTML preview: reference via `<img src="assets/photos/rabbit-barnaby.jpg">`

## What's Here Now

Until you add real assets, both the iOS preview and the web preview use inline SVG rabbit silhouettes and gradient shield placeholders. The code is set up to swap them for real files the moment you drop them in.

## Licensing

Every asset you add should have known licensing. Put a `LICENSES.md` next to the assets if using third-party imagery (Unsplash, iStock, etc).

Your own photos: no license needed, but include a `CREDITS.md` noting who took them if relevant.

AI-generated: note the tool and prompt in `CREDITS.md` — useful for future edits.
