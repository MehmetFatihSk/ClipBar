// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipBar",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ClipBar",
            path: "Sources/ClipBar"
        )
    ]
)
