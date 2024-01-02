// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Turf",
    platforms: [
        .macOS(.v10_13), .iOS(.v11), .watchOS(.v4), .tvOS(.v11),
    ],
    products: [
        .library(
            name: "Turf",
            targets: ["Turf"]
        ),
    ],
    targets: [
        .target(
            name: "Turf",
            dependencies: [],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TurfTests",
            dependencies: ["Turf"],
            exclude: ["Info.plist", "Fixtures/simplify"],
            resources: [
                .process("Fixtures"),
            ],
            swiftSettings: [.define("SPM_TESTING")]
        ),
    ]
)

//for target in package.targets where target.type != .system {
//  target.swiftSettings = target.swiftSettings ?? []
//  target.swiftSettings?.append(
//    .unsafeFlags([
//      "-emit-module-interface", "-enable-library-evolution",
//      "-Xfrontend", "-warn-concurrency",
//      "-Xfrontend", "-enable-actor-data-race-checks",
//      "-Xfrontend", "-require-explicit-sendable",
//    ])
//  )
//}
