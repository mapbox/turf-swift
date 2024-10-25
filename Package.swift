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
            url: "https://github.com/mapbox/turf-swift/releases/download/v3.2.14/Turf.xcframework.zip",
            checksum: "a26ce1347b882e56d9b0b85d05f64caa75aac0996b1beaadb57e4acf3fd94fa1" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
