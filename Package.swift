// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineCoreData",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "CombineCoreData",
            targets: ["CombineCoreData"]),
    ],
    targets: [
        .target(
            name: "CombineCoreData",
            dependencies: []),
        .target(
            name: "Books",
            dependencies: ["CombineCoreData"]),
        .testTarget(
            name: "CombineCoreDataTests",
            dependencies: ["CombineCoreData", "Books"]),
    ]
)
