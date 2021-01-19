// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let checksum = "1439833d0c02c34e26435090a20b4741febc896e019adc2c3b92988788189b77"
let url = "https://github.com/mapbox/turf-swift/releases/download/v2.0.0-alpha.1/Turf.xcframework.zip"

let package = Package(
    name: "Turf",
    platforms: [.iOS(.v10), .macOS(.v10_15)],
    products: [
        .library(
            name: "Turf",
            targets: ["Turf"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "Turf", url: url, checksum: checksum)
    ],
    cxxLanguageStandard: .cxx14
)
