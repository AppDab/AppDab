// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AppDab",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "AppDabActions",
            targets: ["AppDabActions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MortenGregersen/Bagbutik", .branch("main")),
        .package(url: "https://github.com/cbaker6/CertificateSigningRequest.git", from: "1.27.0"),
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
                .product(name: "xchtmlreportcore", package: "XCTestHTMLReport"),
            ]),
        .testTarget(
            name: "AppDabActionsTests",
            dependencies: ["AppDabActions"]),
    ])
