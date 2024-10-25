// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Turf",
    platforms: [
        .macOS(.v10_13), .iOS(.v11), .watchOS(.v4), .tvOS(.v11), .custom("visionos", versionString: "1.0")
    ],
    products: [
        .library(name: "Turf", targets: ["Turf"]),
    ],
    targets: [
        .binaryTarget(
            name: "Turf",
            url: "https://github.com/mapbox/turf-swift/releases/download/v0.0.0/Turf.xcframework.zip",
            checksum: "1e096b58628187263095f176dc67b6a4a272ea35bec11d88a5306acdea18f8fd" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
