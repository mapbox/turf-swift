// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "GeoJSONKitTurf",
  platforms: [
    .macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15),
    .custom("xros", versionString: "1.0")
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
    .package(url: "https://github.com/maparoni/geojsonkit.git", from: "0.5.2"),
//    .package(name: "GeoJSONKit", path: "../GeoJSONKit"),
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
  ],
  targets: [
    .target(
      name: "GeoJSONKitTurf",
      dependencies: [
        .product(name: "GeoJSONKit", package: "geojsonkit"),
      ]),
    .executableTarget(
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
