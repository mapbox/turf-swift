// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GeoJSONKitTurf",
  platforms: [
    .macOS(.v10_12), .iOS(.v10), .watchOS(.v3), .tvOS(.v12),
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "GeoJSONKitTurf",
      targets: ["GeoJSONKitTurf"]),
  ],
  dependencies: [
    .package(name: "GeoJSONKit", url: "https://github.com/maparoni/geojsonkit.git", from: "0.3.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "GeoJSONKitTurf",
      dependencies: ["GeoJSONKit"]),
    .testTarget(
      name: "GeoJSONKitTurfTests",
      dependencies: ["GeoJSONKitTurf"],
      exclude: ["Fixtures"]),
  ]
)
