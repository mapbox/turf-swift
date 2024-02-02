// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Turf",
    platforms: [
        .macOS(.v10_13), .iOS(.v11), .watchOS(.v4), .tvOS(.v11), .custom("visionos", versionString: "1.0")
    ],
    products: [
        .library(
            name: "Turf",
            targets: ["Turf"]
        ),
    ],
    targets: [
        .target(
            name: "Turf",
            dependencies: [],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TurfTests",
            dependencies: ["Turf"],
            exclude: ["Info.plist", "Fixtures/simplify"],
            resources: [
                .process("Fixtures"),
            ],
            swiftSettings: [.define("SPM_TESTING")]
        ),
    ]
)
