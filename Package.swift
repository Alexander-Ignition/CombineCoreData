// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataCombine",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15"),
        .tvOS("13.0"),
        .watchOS("6.0")
    ],
    products: [
        .library(
            name: "CoreDataCombine",
            targets: ["CoreDataCombine"]),
    ],
    targets: [
        .target(
            name: "CoreDataCombine",
            dependencies: []),
        .testTarget(
            name: "CoreDataCombineTests",
            dependencies: ["CoreDataCombine"]),
    ]
)
