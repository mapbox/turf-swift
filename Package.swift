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
            url: "https://github.com/mapbox/turf-swift/releases/download/v3.2.17/Turf.xcframework.zip",
            checksum: "c209493b5664c3f85d1cd02ee2fc369826bee42f8494885bdb53441b49a28f69" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
