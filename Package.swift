// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScreamURITemplate",
    products: [
        .library(
            name: "ScreamURITemplate",
            targets: ["ScreamURITemplate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ScreamURITemplate",
            dependencies: [],
            resources: [.process("PrivacyInfo.xcprivacy")]),
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
        .executableTarget(
            name: "ScreamURITemplateExample",
            dependencies: ["ScreamURITemplate"]),
    ],
    swiftLanguageModes: [.v6])
