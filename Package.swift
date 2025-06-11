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
        .package(url: "https://github.com/MortenGregersen/Bagbutik", from: "17.0.0"),
        .package(url: "https://github.com/cbaker6/CertificateSigningRequest", from: "1.30.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),
        .package(url: "https://github.com/thii/xcbeautify", from: "2.15.0"),
        .package(url: "https://github.com/TitouanVanBelle/XCTestHTMLReport", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "AppDabActions",
            dependencies: [
                .product(name: "Bagbutik", package: "Bagbutik"),
                "CertificateSigningRequest",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "XcbeautifyLib", package: "xcbeautify"),
                .product(name: "xchtmlreportcore", package: "XCTestHTMLReport", condition: .when(platforms: [.macOS, .macCatalyst])),
            ]),
        .testTarget(
            name: "AppDabActionsTests",
            dependencies: ["AppDabActions"],
            resources: [
                .copy("Actions/Apps/AppStoreVersion/Localization/screenshot1.png"),
                .copy("Actions/Uploading/Binary-Info.plist")
            ]),
        .target(
            name: "AppDabRunner",
            dependencies: [
                "AppDabActions",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ])
