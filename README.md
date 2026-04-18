# HerdMaster

Rabbit breeding herd management for ARBA members.

## Project layout

```
.
├── HerdMaster.xcodeproj/          Xcode project (commit this)
├── Sources/
│   ├── HerdMasterApp/            iOS app entry point
│   ├── HerdMasterCore/          Pure Foundation (Evans models, parser)
│   │   ├── EvansModels.swift     Animal/Pedigree value types
│   │   └── Services/
│   │       └── EvansHTMParser.swift
│   └── HerdMasterUI/             SwiftUI + SwiftData + CloudKit + StoreKit 2
│       ├── Models/               @Model types
│       ├── Theme/               Colors / Typography / Spacing
│       ├── Components/          Reusable views
│       └── Services/           CloudKit sync, StoreKit 2
├── Design/                      Web preview
└── Docs/                       Architecture
```

## Quick start

```bash
# Open in Xcode
open HerdMaster.xcodeproj

# Build
xcodebuild -project HerdMaster.xcodeproj -scheme HerdMaster -destination 'iPhone 17' build
```

## Targets

| Target      | Platforms | Frameworks                              |
|------------|----------|---------------------------------------|
| HerdMaster  | iOS 17   | SwiftUI, SwiftData, CloudKit, StoreKit 2 |

## Design system

Theme tokens in `Sources/HerdMasterUI/Theme/`:
- `Colors.swift` — Color palette
- `Typography.swift` — Font styles  
- `Spacing.swift` — Spacing scale

## Tooling

- Xcode 16+
- Swift 6.0
- iOS 17+