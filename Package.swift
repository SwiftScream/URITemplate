// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ScreamURITemplate",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "ScreamURITemplate",
            targets: ["ScreamURITemplate"]),
        .library(
            name: "ScreamURITemplateMacros",
            targets: ["ScreamURITemplateMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "600.0.1"),
    ],
    targets: [
        .target(
            name: "ScreamURITemplate",
            resources: [.process("PrivacyInfo.xcprivacy")]),
        .target(
            name: "ScreamURITemplateMacros",
            dependencies: ["ScreamURITemplate", "ScreamURITemplateCompilerPlugin"]),
        .macro(
            name: "ScreamURITemplateCompilerPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "ScreamURITemplate",
            ]),
        .testTarget(
            name: "ScreamURITemplateTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "ScreamURITemplate",
                "ScreamURITemplateCompilerPlugin",
            ],
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
            dependencies: ["ScreamURITemplate", "ScreamURITemplateMacros"]),
    ],
    swiftLanguageModes: [.v6])
