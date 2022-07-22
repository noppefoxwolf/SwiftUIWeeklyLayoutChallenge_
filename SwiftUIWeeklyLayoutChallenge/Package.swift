// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftUIWeeklyLayoutChallenge",
    defaultLocalization: "ja",
    platforms: [.iOS("16"), .macOS(.v10_15), .macCatalyst(.v13), .tvOS("16"), .watchOS("9")],
    products: [
        .library(
            name: "SwiftUIWeeklyLayoutChallenge",
            targets: ["SwiftUIWeeklyLayoutChallenge"]),
    ],
    targets: [
        .target(
            name: "SwiftUIWeeklyLayoutChallenge",
            path: "."),
    ]
)
