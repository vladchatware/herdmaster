# HerdMaster Preview

SwiftUI architectural preview for the HerdMaster iOS app. Built to demonstrate the three areas you flagged: CloudKit sync with conflict resolution, Evans HTM import, and StoreKit 2 subscription handling. Built in SwiftUI + SwiftData + CloudKit exactly as HerdMaster would be built.

## What This Demonstrates

### 1. CloudKit Conflict Resolution (`Services/CloudKitSync.swift`, `Models/Animal.swift`)

The three-tier merge policy I described:

- **Scalar low-stakes fields** (weight, notes, color) - last-write-wins via `CKRecord.modificationDate`, logged for audit
- **Relational fields** (sire/dam, offspring) - `recordChangeTag` for optimistic concurrency, throws `CKError.serverRecordChanged` on mismatch
- **Breeding-critical fields** (litter count, kit records, breeding date) - never auto-merge, surface to manual resolution

Key caveats handled:
- `@Attribute(.unique)` causes CloudKit sync failures (iOS 18) - not used on synced models
- Cross-device uniqueness enforced in code via existence check before insert
- Delete propagation via `NSPersistentCloudKitContainer` automatic tombstones and change tokens
- Sync events observed via `NSPersistentCloudKitContainer.eventChangedNotification`

### 2. Evans HTM Parser (`Services/EvansHTMParser.swift`)

Actual working parser for real Evans Rabbit Register HTM files. Run the tests (`EvansHTMParserTests.swift`) against the included 3C Rabbitry sample (`Samples/evans-sample.htm`).

Handles:
- Encoding fallback chain (UTF-8 → Windows-1252 → ISO-8859-1) for legacy Windows exports
- HTML entity decoding (`&nbsp;` → space) before DateFormatter parsing
- Weight format: `"3 # 8 oz"` = 3 pounds 8 ounces (Evans-specific)
- Sex detection via CSS class (`.male`, `.female`, `.neuter`)
- Positional parent inference via column + row in table layout
- Per-record transactions (one bad record never fails the file)
- Visual diff validation against source HTM screenshot

### 3. StoreKit 2 Subscription (`Services/StoreKit2Manager.swift`)

- `Transaction.updates` listener at app launch
- `Transaction.currentEntitlements` check for tier gating
- Tier enum (Free, Breeder) with gate modifier
- Ready for App Store Connect product configuration

### 4. Design System from Figma (`DesignSystem/`)

Extracted tokens from the HerdMaster Figma (App, Extra1, Extra2, Var folders):

- **Colors:** Dark navy backgrounds (#0F172A, #1E293B), teal accents (#14B8A6, #0F766E), pedigree sex colors matching Evans convention (male blue, female pink, placeholder green)
- **Typography:** Serif headers (Lora-style), sans-serif body (system font fallback), display weights for stat tiles
- **Spacing:** 8pt grid with 4/8/12/16/24/32 scale
- **Components:** `AnimalCard`, `StatTile`, `PedigreeCell`, `PrimaryButton`, `TabBar`

### 5. Pixel-Perfect Screens from Figma

Two screens built to pixel-perfect match:
- **Onboarding flow** (`Views/Onboarding/OnboardingView.swift`) - splash, path selection (ARBA Member vs Independent Breeder)
- **Herd List** (`Views/Herd/HerdListView.swift`) - animal cards with status, quick actions, breed groupings
- **4-Gen Pedigree Grid** (`Views/Pedigree/PedigreeGridView.swift`) - visual tree with sex-coded cells matching Evans convention

## Architecture Decisions

### SwiftData Over Core Data
- Modern type-safe API
- Less boilerplate
- Works with `NSPersistentCloudKitContainer` via backing Core Data store
- Caveat: all properties optional or defaulted, all relationships optional (required for CloudKit)

### CloudKit Over Custom Backend for MVP
- Apple absorbs most sync cost at scale
- Automatic silent push + retry + exponential backoff
- No BGTaskScheduler needed for sync (system-scheduled)
- Delete propagation automatic via change tokens

### Custom Write-Ahead Log for Non-CloudKit Paths
- ARBA promo Node.js backend sync needs WAL pattern
- Appendable, checksummed log entries
- Idempotent replay on next launch after crash/offline
- Not needed for pure CloudKit sync (handled automatically)

## How to Run

1. Open `HerdMasterPreview.xcodeproj` in Xcode 15+
2. Select iOS Simulator (iPhone 15 Pro recommended)
3. Build and run (Cmd+R)
4. Tab through the three demo screens
5. Run tests: Cmd+U (Evans HTM parser tests execute against real sample)

## File Map

```
HerdMasterPreview/
├── HerdMasterPreviewApp.swift       # App entry, CloudKit container init
├── ContentView.swift                # Demo tab navigation
├── DesignSystem/
│   ├── Colors.swift                 # Figma color tokens
│   ├── Typography.swift             # Figma typography
│   ├── Spacing.swift                # 8pt grid scale
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── AnimalCard.swift
│       ├── StatTile.swift
│       └── PedigreeCell.swift
├── Models/
│   ├── Animal.swift                 # SwiftData model, CloudKit-safe
│   ├── BreedingRecord.swift         # Breeding-critical field handling
│   ├── SyncConflict.swift           # Manual conflict UI model
│   └── ARBATier.swift               # Subscription tier enum
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # Pixel-perfect from Figma Var
│   ├── Herd/
│   │   └── HerdListView.swift       # Pixel-perfect from Figma App
│   ├── Pedigree/
│   │   └── PedigreeGridView.swift   # 4-gen visual tree
│   └── AnimalDetail/
│       └── AnimalDetailView.swift
├── Services/
│   ├── CloudKitSync.swift           # NSPersistentCloudKitContainer + conflict resolution
│   ├── EvansHTMParser.swift         # Real HTM parser with SwiftSoup
│   ├── SyncService.swift            # Write-ahead log for REST paths
│   └── StoreKit2Manager.swift       # Subscription tier gate
└── Samples/
    ├── evans-sample.htm             # 3C Rabbitry pedigree (from Joseph)
    └── evans-rendered-screenshot.png # Visual reference for parser validation

HerdMasterPreviewTests/
├── EvansHTMParserTests.swift        # Tests against real sample
└── AnimalModelTests.swift           # SwiftData model tests
```

## What I Didn't Build In This Preview

Intentionally scoped. These are real design decisions for M1-M2 in the production build:
- Schema finalization (needs Figma walkthrough with you)
- Conflict UX layout (needs Figma)
- Error view layout (needs Figma + state decisions)
- Full navigation flow (needs Figma)
- Moon calendar J2000 engine (M6)
- PDFKit pedigree template (M3, needs your mockup approval)
- Windows Companion utility (M17, separate codebase)

Same patterns I'd use for the real M1 spike if we move forward. You see actual code before deciding.

## Notes on Swift / SwiftUI / SwiftData Currency

Verified against current Apple documentation as of iOS 18:
- `NSPersistentCloudKitContainer.eventChangedNotification` API
- `CKRecord.modificationDate` + `recordChangeTag`
- `Transaction.updates` StoreKit 2 listener
- SwiftData `@Model`, `@Relationship(deleteRule:inverse:)`, `@Attribute(.unique)` caveats

No guessed APIs, no outdated patterns.
