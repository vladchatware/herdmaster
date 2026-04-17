// swift-tools-version: 6.0
// HerdMaster — rabbit breeding herd management for ARBA members.
import PackageDescription

let package = Package(
    name: "HerdMaster",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "HerdMasterCore", targets: ["HerdMasterCore"]),
        .library(name: "HerdMasterUI", targets: ["HerdMasterUI"])
    ],
    targets: [
        // Pure Swift, platform-agnostic. Runs on Linux.
        // Evans HTM parser, data models, domain logic.
        .target(
            name: "HerdMasterCore",
            path: "Sources/HerdMasterCore"
        ),

        // SwiftUI + SwiftData + CloudKit + StoreKit 2. Apple platforms only.
        // Screens, view models, design system, Apple-framework services.
        .target(
            name: "HerdMasterUI",
            dependencies: ["HerdMasterCore"],
            path: "Sources/HerdMasterUI"
        ),

        .testTarget(
            name: "HerdMasterCoreTests",
            dependencies: ["HerdMasterCore"],
            path: "Tests/HerdMasterCoreTests",
            resources: [.copy("Resources/evans-sample.htm")]
        )
    ]
)
