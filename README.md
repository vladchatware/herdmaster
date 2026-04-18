# HerdMaster

Rabbit breeding herd management for ARBA members. iOS-first.

## Project layout

```
.
├── HerdMaster.xcodeproj/          Xcode project
├── Package.swift                备用：Swift包清单
├── Sources/
│   ├── HerdMasterCore/           Pure Foundation (Evans models, parser)
│   │   ├── EvansModels.swift      Animal/Pedigree value types
│   │   └── Services/
│   │       └── EvansHTMParser.swift
│   ├── HerdMasterUI/             SwiftUI + SwiftData + CloudKit + StoreKit 2
│   │   ├── Models/              @Model types
│   │   ├── Theme/              Colors / Typography / Spacing
│   │   ├── Components/         Reusable views
│   │   └── Services/           CloudKit sync, StoreKit 2
│   └── HerdMasterApp/           iOS app entry
├── Design/                      Web preview assets
└── Docs/                       Architecture docs
```

## Quick start

```bash
# Open in Xcode
open HerdMaster.xcodeproj

# Build via command line
xcodebuild -project HerdMaster.xcodeproj -scheme HerdMaster -destination 'iPhone 17' build
```

## Targets

| Target          | Platforms        | Frameworks                                      |
|----------------|-----------------|------------------------------------------------|
| HerdMaster     | iOS 17          | SwiftUI, SwiftData, CloudKit, StoreKit 2            |

## Design system

Theme tokens live in `Sources/HerdMasterUI/Theme/`:
- `Colors.swift` — Color palette
- `Typography.swift` — Font styles
- `Spacing.swift` — Spacing scale

The web preview in `Design/` mirrors the Swift tokens.

## Tooling

- Xcode 16+
- Swift 6.0 toolchain
- iOS 17+ deployment target