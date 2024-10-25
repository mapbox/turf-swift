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
            checksum: "a282195b25fcaf72532457c3ab8bd5a80d3172e9cd48e22623a8a2d65eb03a1f" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
