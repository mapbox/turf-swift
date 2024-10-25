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
            url: "https://github.com/mapbox/turf-swift/releases/download/v3.2.15/Turf.xcframework.zip",
            checksum: "dd5f94339a2014c9caf869f51e3573974a94f0f134a2131e3894357a9b2303bc" // checksum will be calculated and available in the release baranch from which actual SwiftPM release is done
        ),
    ]
)
