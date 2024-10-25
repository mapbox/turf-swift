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
            checksum: "e0389e7826ced9a21e5106b88cb50fe7d7db2b72854d2ab881ce668ca759bf81" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
