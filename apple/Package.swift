// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GandalfSync",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "GandalfSync", targets: ["GandalfSync"]),
    ],
    targets: [
        .target(
            name: "GandalfSync",
            path: "Sources/GandalfSync"
        ),
        .testTarget(
            name: "GandalfSyncTests",
            dependencies: ["GandalfSync"],
            path: "Tests/GandalfSyncTests"
        ),
    ]
)
