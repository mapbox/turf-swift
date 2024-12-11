// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// In order to keep Linux comatibility we leave the source based target for Linux.
/// Apple platforms will use the binary target in order to be compatible with binary dependency in MapboxSDK stack.
#if canImport(Darwin)
let targets: [Target] = [
    .binaryTarget(
        name: "Turf",
        url: "https://github.com/mapbox/turf-swift/releases/download/v4.0.0/Turf.xcframework.zip",
        checksum: "ce43384a6f875ab4becdd6bdb7ca60447e5e9133f2acf325dc57be381b52a34c"
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