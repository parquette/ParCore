// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ParCore",
    products: [
        .library(
            name: "ParCore",
            targets: ["ParCore"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ParCore",
            dependencies: []),
        .testTarget(
            name: "ParCoreTests",
            dependencies: ["ParCore"]),
    ]
)
