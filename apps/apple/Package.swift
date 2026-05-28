// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Monkeyword",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MonkeywordCore",
            targets: ["MonkeywordCore"]
        ),
        .executable(
            name: "Monkeyword",
            targets: ["Monkeyword"]
        )
    ],
    targets: [
        .target(
            name: "MonkeywordCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "MonkeywordFixtureCheck",
            dependencies: ["MonkeywordCore"],
            path: "Tests/MonkeywordFixtureCheck"
        ),
        .plugin(
            name: "FixtureValidationPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "MonkeywordFixtureCheck")
            ]
        ),
        .executableTarget(
            name: "Monkeyword",
            dependencies: ["MonkeywordCore"],
            exclude: ["Resources/Info.plist"]
        ),
        .testTarget(
            name: "MonkeywordTests",
            dependencies: ["MonkeywordCore"],
            plugins: ["FixtureValidationPlugin"]
        )
    ]
)
