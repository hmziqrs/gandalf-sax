// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GandalfShared",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "GandalfShared", targets: ["GandalfShared"]),
    ],
    targets: [
        .target(
            name: "GandalfShared",
            path: "Sources/GandalfShared"
        ),
        .testTarget(
            name: "GandalfSharedTests",
            dependencies: ["GandalfShared"]
        ),
    ]
)
