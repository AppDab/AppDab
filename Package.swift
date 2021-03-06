// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AppDab",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "AppDabActions",
            targets: ["AppDabActions"]),
        .library(
            name: "AppDabRunner",
            targets: ["AppDabRunner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MortenGregersen/Bagbutik", from: "2.1.1"),
        .package(url: "https://github.com/cbaker6/CertificateSigningRequest", from: "1.27.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/thii/xcbeautify", from: "0.9.1"),
        .package(url: "https://github.com/TitouanVanBelle/XCTestHTMLReport", .branch("develop")),
    ],
    targets: [
        .target(
            name: "AppDabActions",
            dependencies: [
                "Bagbutik",
                "CertificateSigningRequest",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "XcbeautifyLib", package: "xcbeautify"),
                .product(name: "xchtmlreportcore", package: "XCTestHTMLReport", condition: .when(platforms: [.macOS, .macCatalyst])),
            ]),
        .testTarget(
            name: "AppDabActionsTests",
            dependencies: ["AppDabActions"],
            resources: [.copy("Actions/Apps/AppStoreVersion/Localization/screenshot1.png")]),
        .target(
            name: "AppDabRunner",
            dependencies: [
                "AppDabActions",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ])
