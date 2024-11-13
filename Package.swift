// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// In order to keep Linux comatibility we leave the source based target for Linux.
/// Apple platforms will use the binary target in order to be compatible with binary dependency in MapboxSDK stack.
#if canImport(Darwin)
let targets: [Target] = [
    .binaryTarget(
        name: "Turf",
        url: "https://github.com/mapbox/turf-swift/releases/download/v4.0.0-rc.1/Turf.xcframework.zip",
        checksum: "06d8499f9f4067b0931fbfb1f48161ab49c59f9bdef691be33644656b475fd77"
    )
]
#else
let targets: [Target] = [
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
    )
]
#endif

let package = Package(
    name: "Turf",
    platforms: [
        .macOS(.v10_13), .iOS(.v11), .watchOS(.v4), .tvOS(.v11), .custom("visionos", versionString: "1.0")
    ],
    products: [
        .library(name: "Turf", targets: ["Turf"]),
    ],
    targets: targets
)