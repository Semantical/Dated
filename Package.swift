// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Dated",
    platforms: [
        .iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .tvOS(.v17), .watchOS(.v10),
    ],
    products: [
        .library(
            name: "Dated",
            targets: ["Dated"]
        )
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
