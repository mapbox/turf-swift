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
            url: "https://github.com/mapbox/turf-swift/releases/download/v3.2.12/Turf.xcframework.zip",
            checksum: "57898208f2c031c3c0f034fe6b4d022c48f5fd46a2f7436f27823c205cff8371" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
