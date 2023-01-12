// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "ScreamURITemplate",
    products: [
        .library(
            name: "ScreamURITemplate",
            targets: ["ScreamURITemplate"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ScreamURITemplate",
            dependencies: []),
        .testTarget(
            name: "ScreamURITemplateTests",
            dependencies: ["ScreamURITemplate"],
            resources: [
                .process("data/tests.json"),
                .process("data/uritemplate-test/spec-examples.json"),
                .process("data/uritemplate-test/spec-examples-by-section.json"),
                .process("data/uritemplate-test/extended-tests.json"),
                .process("data/uritemplate-test/negative-tests.json"),
            ]),
        .executableTarget(
            name: "ScreamURITemplateExample",
            dependencies: ["ScreamURITemplate"]),
    ],
    swiftLanguageVersions: [.v5])
