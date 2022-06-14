// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "GeoJSONKitTurf",
  platforms: [
    .macOS(.v10_12), .iOS(.v10), .watchOS(.v3), .tvOS(.v12),
  ],
  products: [
    .library(
      name: "GeoJSONKitTurf",
      targets: ["GeoJSONKitTurf"]),
    .executable(
      name: "geokitten",
      targets: ["GeoKitten"]),
  ],
  dependencies: [
    .package(name: "GeoJSONKit", url: "https://github.com/maparoni/geojsonkit.git", from: "0.5.2"),
//    .package(name: "GeoJSONKit", path: "../GeoJSONKit"),
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
  ],
  targets: [
    .target(
      name: "GeoJSONKitTurf",
      dependencies: ["GeoJSONKit"]),
    .target(
      name: "GeoKitten",
      dependencies: [
        "GeoJSONKitTurf",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(
      name: "GeoJSONKitTurfTests",
      dependencies: ["GeoJSONKitTurf"],
      exclude: ["Fixtures"]),
  ]
)
