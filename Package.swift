// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HerdMasterCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "HerdMasterCore",
            targets: ["HerdMasterCore"]
        )
    ],
    targets: [
        .target(
            name: "HerdMasterCore",
            path: "Sources/HerdMasterCore"
        ),
        .testTarget(
            name: "HerdMasterCoreTests",
            dependencies: ["HerdMasterCore"],
            path: "Tests/HerdMasterCoreTests",
            resources: [
                .copy("Resources/evans-sample.htm")
            ]
        )
    ]
)
