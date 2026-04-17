# HerdMasterPreview - Setup Instructions

## Quick Start (5 minutes)

1. Open Xcode 15.4 or later
2. File → New → Project → iOS → App
3. Settings:
   - Product Name: `HerdMasterPreview`
   - Team: your Apple Developer team
   - Interface: SwiftUI
   - Language: Swift
   - Storage: **SwiftData + CloudKit** (both checked)
   - Include Tests: Yes
4. Save the project wherever (the generated folder matters less than what we drag in)
5. **Delete** Xcode's auto-generated `ContentView.swift` and `HerdMasterPreviewApp.swift` (we're replacing them)
6. In Finder, open this `HerdMasterPreview/` folder and drag ALL the subfolders into Xcode's project navigator:
   - `HerdMasterPreview/DesignSystem/`
   - `HerdMasterPreview/Models/`
   - `HerdMasterPreview/Services/`
   - `HerdMasterPreview/Views/`
   - `HerdMasterPreview/Samples/` (select "Create folder references" so the HTM file is bundled)
   - `HerdMasterPreview/HerdMasterPreviewApp.swift`
7. Drag `HerdMasterPreviewTests/EvansHTMParserTests.swift` into the test target
8. In the project settings:
   - Under Signing & Capabilities, enable iCloud + CloudKit
   - Add an iCloud container: `iCloud.com.yourteam.HerdMasterPreview`
9. Build and run (Cmd+R)

## What You'll See When It Runs

**Tab 1: Onboarding** - Pixel-perfect splash screen with ARBA Member / Independent Breeder path selection

**Tab 2: Herd** - Animal list with search, filter tabs, status badges. Pre-seeded with 4 animals from the Evans sample.

**Tab 3: Import** - Tap "Parse Sample HTM" to run the Evans parser live against the included 3C Rabbitry pedigree file. Shows extracted rabbitry, breed, owner, all 9 animals with their data.

**Tab 4: Pedigree** - 4-generation visual tree from the parsed sample. Sex-coded cells matching Evans convention.

## Run the Tests

Cmd+U runs the full test suite including:
- `testParsesRabbitryAndBreed` - confirms header extraction
- `testParsesSubjectAnimal` - confirms 3C RUBY is parsed correctly
- `testParsesDateWithNbspSeparators` - critical: dates with `&nbsp;` between tokens parse correctly
- `testParsesWeightFormat` - Evans pound-symbol format `3 # 8 oz` = 56 oz
- `testDetectsSexViaClass` - male/female/neuter class detection
- `testGrandChampionAndLegs` - GC and Legs field extraction
- `testOwnerExtraction` - owner name + email
- `testHTMLEntityDecoding` - entity handling before DateFormatter

All 8 should pass. The HTML entity test is the subtle one - most devs miss that `&nbsp;` doesn't work with DateFormatter.

## File Map

```
HerdMasterPreview/
├── HerdMasterPreviewApp.swift     # App entry, SwiftData container
├── DesignSystem/
│   ├── Colors.swift               # Figma tokens (navy/teal/pedigree colors)
│   ├── Typography.swift           # Serif headers + sans body
│   ├── Spacing.swift              # 8pt grid
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── AnimalCard.swift
│       ├── StatTile.swift
│       └── PedigreeCell.swift
├── Models/
│   ├── Animal.swift               # SwiftData @Model, CloudKit-safe
│   ├── BreedingRecord.swift       # Breeding with critical field protection
│   └── SyncConflict.swift         # Manual conflict surface model
├── Services/
│   ├── CloudKitSync.swift         # NSPersistentCloudKitContainer + 3-tier merge policy
│   ├── EvansHTMParser.swift       # Working parser (no SwiftSoup needed)
│   └── StoreKit2Manager.swift     # Transaction.updates + currentEntitlements
├── Views/
│   ├── Onboarding/OnboardingView.swift
│   ├── Herd/HerdListView.swift
│   ├── EvansImportDemoView.swift
│   ├── PedigreeDemoView.swift
│   └── Pedigree/PedigreeGridView.swift
└── Samples/
    ├── evans-sample.htm            # 3C Rabbitry sample for parser testing
    └── evans-rendered-screenshot.png

HerdMasterPreviewTests/
└── EvansHTMParserTests.swift      # 8 tests against the real sample
```

## Customization Notes

- **CloudKit container name**: update in `CloudKitSync.configure(modelName:)` to match your iCloud container
- **StoreKit products**: add `com.herdmaster.breeder` in App Store Connect as auto-renewable subscription
- **Design tokens**: all colors/typography/spacing live in `DesignSystem/` - single source of truth
- **Evans sample**: drop additional Evans HTM exports into `Samples/` and add a test case

## Known Limitations (Intentional for Preview Scope)

This is a capability preview, not the production app. What's NOT here:
- Full navigation + deep links
- Every error state and empty state
- Push notification permissions + scheduling
- PDFKit pedigree export template (M3 in production plan)
- Moon calendar J2000 engine (M6)
- Breeding wizard full flow (M5)
- Windows Companion utility (M17)
- Complete StoreKit product configuration
- Production-hardened DDI checks (needs paid license per SRS research)

Each would be a discrete milestone in the real build. This preview demonstrates the foundations are solid and the patterns are production-ready.
