// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotepadPlusPlus",
    platforms: [
        .macOS("14.0"),
        .iOS("17.0")
    ],
    products: [
        .executable(
            name: "NotepadPlusPlus",
            targets: ["NotepadPlusPlus"]
        )
    ],
    targets: [
        .executableTarget(
            name: "NotepadPlusPlus",
            path: "Sources"
        )
    ]
)
