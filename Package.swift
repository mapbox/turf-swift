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
        checksum: "a846a91335e8ae4f6df29c9c72a621b642071de1b800c239d573b732622121e6"
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