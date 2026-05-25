// swift-tools-version: 5.9
//
// Platzhalter-Konvention:
//   PROJEKT_NAME     = Distribution-Name (z. B. "my-tool")
//   PROJEKT_PACKAGE  = Swift-Package-Name in PascalCase (z. B. "MyTool")
//
// Nach dem Interview:
//   1. Hier alle PROJEKT_NAME / PROJEKT_PACKAGE ersetzen.
//   2. Verzeichnis Sources/PROJEKT_PACKAGE/ entsprechend umbenennen.
//   3. Tests/PROJEKT_PACKAGETests/ ebenfalls umbenennen.
//   4. `swift build` ausführen.

import PackageDescription

let package = Package(
    name: "PROJEKT_NAME",
    platforms: [
        .macOS(.v14)   // <-- nach Interview anpassen (.v13 / .iOS(.v17) / …)
    ],
    products: [
        .library(
            name: "PROJEKT_PACKAGE",
            targets: ["PROJEKT_PACKAGE"]
        )
        // Für eine CLI zusätzlich:
        // .executable(name: "PROJEKT_NAME", targets: ["PROJEKT_PACKAGECLI"])
    ],
    dependencies: [
        // Weitere Abhängigkeiten nach Interview ergänzen, z. B.:
        // .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "PROJEKT_PACKAGE",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "PROJEKT_PACKAGETests",
            dependencies: ["PROJEKT_PACKAGE"]
        )
    ]
)
