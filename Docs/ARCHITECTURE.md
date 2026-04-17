# Architecture

## Goals

1. Replace Evans Software's legacy Windows herd manager before its end-of-life,
   for the ~17K active ARBA breeders who depend on it today.
2. Ship the iOS MVP under a 6-week pilot scope without locking out a future
   Mac Catalyst or Android port.
3. Keep domain logic — pedigree math, Evans HTM import, breeding-cycle
   scheduling — outside the SwiftUI layer so it stays testable on Linux CI.

## Module boundaries

```
HerdMasterApp        ─▶  HerdMasterUI  ─▶  HerdMasterCore
  (iOS bundle)           (Apple)            (portable)
```

- `HerdMasterCore` depends only on Foundation. Anything that can avoid SwiftUI,
  SwiftData, or CloudKit imports lives here.
- `HerdMasterUI` adds the Apple frameworks. Each file is wrapped with
  `#if canImport(SwiftUI) && canImport(SwiftData)` so the package still resolves
  on Linux even though the target itself can't compile there.
- `HerdMasterApp` is the iOS bundle target. Owns Info.plist, entitlements,
  scenes, and the root window — nothing else.

## Sync strategy

| Data class                       | Conflict policy                                                  |
| -------------------------------- | ---------------------------------------------------------------- |
| Scalar low-stakes (weight, notes, color) | Last-write-wins via `CKRecord.modificationDate`             |
| Relational (sire/dam, offspring) | Optimistic concurrency via `recordChangeTag`. If two writes land within 60 seconds, surface to manual conflict view rather than auto-merging. |
| Breeding-critical (litter count, kit list, breeding date) | Always manual conflict resolution. Never auto-merge. |

Cross-device uniqueness for ear tags is enforced in app code with an existence
check before insert, because `@Attribute(.unique)` causes CloudKit sync failures
in iOS 18 and is silently ignored on iOS 17.

Delete propagation is handled by `NSPersistentCloudKitContainer`'s server-side
tombstones — no manual tombstone code on the CloudKit path.

## Evans HTM import

`HerdMasterCore.EvansHTMParser` covers four published Evans export versions
(v10/12/14/15). Specifics:

- Encoding fallback chain: UTF-8 → Windows-1252 → ISO-8859-1.
- HTML entities (`&nbsp;` etc.) are normalised to plain ASCII before any
  `DateFormatter` work runs — Evans dates use NBSP separators.
- Sex is read from the HTML class (`.male` / `.female` / `.neuter`) which
  matches Evans' internal convention.
- Weight uses Evans' `# pounds # ounces` format and is stored in raw ounces.
- Each record commits in its own transaction so a single malformed entry never
  fails the whole import.

## Risks worth flagging in the M1 spike

1. The 100-files-in-30s benchmark on iPhone 12 (TC-05) — validate in week 7
   rather than at M4 acceptance. Fallback is parallel parsing with batched
   commits.
2. CloudKit silent failure modes around `@Attribute(.unique)` — the in-app
   uniqueness check is the only protection we get.
3. PDFKit pedigree templates require the M1 mockup approval gate before they
   can be built.

## Why two themes

The web preview in `Design/` is intentionally independent of Swift. It exists
so design changes (typography, colour, spacing) can be reviewed and signed off
before they reach an iOS build. Token names are kept identical between the two
sides:

| Swift (HerdMasterUI/Theme)              | CSS (Design/theme)                |
| --------------------------------------- | --------------------------------- |
| `HMColor.surfacePage`                   | `--color-surface-page`            |
| `HMColor.accent`                        | `--color-accent`                  |
| `HMSpace.lg` (16pt)                     | `--space-4` (16px)                |
| `HMRadius.md` (12pt)                    | `--radius-md` (12px)              |

When tokens diverge, both sides are wrong — pick one and update both in the
same commit.
