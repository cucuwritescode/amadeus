// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Amadeus",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Amadeus",
            targets: ["Amadeus"])
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/Tonic.git", from: "1.0.6")
    ],
    targets: [
        .target(
            name: "Amadeus",
            dependencies: ["AudioKit", "Tonic"])
    ]
)