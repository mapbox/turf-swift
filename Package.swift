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
            url: "https://github.com/mapbox/turf-swift/releases/download/v3.2.19/Turf.xcframework.zip",
            checksum: "d7cbde7435122eb7b605c6f0c21432af06dac5c8b2d83199373973a98fda6e3c" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
