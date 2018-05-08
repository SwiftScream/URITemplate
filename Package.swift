// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "URITemplate",
    products: [
        .library(
            name: "URITemplate",
            targets: ["URITemplate"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "URITemplate",
            dependencies: [],
            path: "Source"),
    ]
)
