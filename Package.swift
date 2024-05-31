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
            exclude: [
                "data/uritemplate-test/json2xml.xslt",
                "data/uritemplate-test/LICENSE",
                "data/uritemplate-test/README.md",
                "data/uritemplate-test/transform-json-tests.xslt",
            ],
            resources: [
                .process("data/tests.json"),
                .process("data/uritemplate-test/spec-examples.json"),
                .process("data/uritemplate-test/spec-examples-by-section.json"),
                .process("data/uritemplate-test/extended-tests.json"),
                .process("data/uritemplate-test/negative-tests.json"),
            ]),
    ],
    swiftLanguageVersions: [.v5])

#if swift(>=5.6) || os(macOS) || os(Linux)
    package.targets.append(
        .executableTarget(
            name: "ScreamURITemplateExample",
            dependencies: ["ScreamURITemplate"])
    )
#endif
