// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KnockDesk",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "KnockDesk", targets: ["KnockDesk"])
    ],
    targets: [
        .executableTarget(
            name: "KnockDesk",
            path: "Sources/KnockDesk"
        )
    ]
)
