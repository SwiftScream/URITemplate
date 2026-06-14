// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScreamURITemplateBenchmarks",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "ScreamURITemplateBenchmark",
            targets: ["ScreamURITemplateBenchmark"]),
    ],
    dependencies: [
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "ScreamURITemplateBenchmark",
            dependencies: [
                .product(name: "ScreamURITemplate", package: "URITemplate"),
            ]),
    ],
    swiftLanguageModes: [.v6])
