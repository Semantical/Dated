// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Dated",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17), .watchOS(.v10), .visionOS(.v1)],
    products: [
        .library(
            name: "Dated",
            targets: ["Dated"]
        ),
    ],
    targets: [
        .target(
            name: "Dated"
        ),
        .testTarget(
            name: "DatedTests",
            dependencies: ["Dated"]
        ),
    ]
)