// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let checksum = "5256bc0056fb35d19f3d4b5a59d9d22e6a2d57e98664e46de656764a71c7d5e0"
let url = "https://github.com/mapbox/turf-swift/releases/download/v2.0.0-alpha.2/Turf.xcframework.zip"

let package = Package(
    name: "Turf",
    platforms: [.iOS(.v10), .macOS(.v10_12)],
    products: [
        .library(
            name: "Turf",
            targets: ["Turf"]),
    ],
    targets: [
        .binaryTarget(name: "Turf", url: url, checksum: checksum),
    ]
)
