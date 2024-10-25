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
            url: "https://github.com/mapbox/turf-swift/releases/download/v3.2.18/Turf.xcframework.zip",
            checksum: "5f306aead15b60529faec2eecd93fe1708507be57845f4951613b52709c72a5c" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
