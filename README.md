# HerdMaster

Rabbit breeding herd management for ARBA members. iOS-first, with Mac Catalyst and Android in later phases.

## Project layout

```
.
├── Package.swift                    SPM manifest — Core (portable) + UI (Apple)
├── project.yml                      xcodegen — regenerates the iOS Xcode project
├── Makefile                         build / test / lint / format / xcode commands
├── Sources/
│   ├── HerdMasterCore/              Pure Foundation. Domain models + parsers.
│   │   ├── EvansModels.swift        Animal/Pedigree value types
│   │   └── Services/
│   │       └── EvansHTMParser.swift Multi-version Evans HTM importer
│   ├── HerdMasterUI/                SwiftUI + SwiftData + CloudKit + StoreKit 2
│   │   ├── Models/                  @Model types (CloudKit-safe)
│   │   ├── Theme/                   Colors / Typography / Spacing tokens
│   │   ├── Components/              Reusable view primitives
│   │   └── Services/                CloudKit sync, StoreKit 2 manager
│   └── HerdMasterApp/               iOS app entry point
├── Tests/
│   └── HerdMasterCoreTests/         Runs on macOS, iOS, and Linux
├── Design/                          HTML/CSS preview of the design system
│   ├── theme/                       Tokens + components mirrored to Swift
│   └── screens/                     sign-in.html, breed-details.html
├── Resources/                       Canonical asset library
└── Docs/
    └── ARCHITECTURE.md              Target boundaries, sync strategy, risks
```

## Quick start

```bash
make test-core      # 10 parser tests, runs anywhere Swift runs
make test           # full suite (Apple platforms)
make xcode          # regenerate HerdMaster.xcodeproj
make design         # serve web preview at http://localhost:8765
```

## Targets

| Target          | Platforms        | Frameworks                                          |
| --------------- | ---------------- | --------------------------------------------------- |
| HerdMasterCore  | iOS / macOS / Linux | Foundation                                       |
| HerdMasterUI    | iOS 17 / macOS 14   | SwiftUI, SwiftData, CloudKit, StoreKit 2         |
| HerdMasterApp   | iOS 17              | HerdMasterUI                                     |

`HerdMasterCore` deliberately stays platform-agnostic. The Evans HTM parser, all
domain types, and any future on-device computation belong here. This keeps tests
fast, runnable on Linux CI, and free of Apple framework dependencies.

`HerdMasterUI` is wrapped with `#if canImport(SwiftUI) && canImport(SwiftData)`
guards so the package still resolves on Linux.

## Design system

The Swift theme tokens (`Sources/HerdMasterUI/Theme/*.swift`) and the web
preview tokens (`Design/theme/tokens.css`) carry identical values. Touch one,
update the other in the same change. The two screens that ship with the preview
are the source of truth for typography, spacing, and component contracts:

- `Design/screens/sign-in.html` — Welcome Back + OAuth
- `Design/screens/breed-details.html` — Pair card, kindling countdown, timeline,
  litter roster

## Tooling

- Swift 6.0 toolchain
- xcodegen for the Xcode project (so it stays out of git)
- swift-format and SwiftLint configs included
- GitHub Actions CI builds Core on Linux + UI on macOS

See `Docs/ARCHITECTURE.md` for the longer write-up.
