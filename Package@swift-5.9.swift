// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ScreamURITemplate",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "ScreamURITemplate",
            targets: ["ScreamURITemplate"]),
        .library(
            name: "ScreamURITemplateMacros",
            targets: ["ScreamURITemplateMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-08-28-a"),
    ],
    targets: [
        .target(
            name: "ScreamURITemplate",
            dependencies: []),
        .target(
            name: "ScreamURITemplateMacros",
            dependencies: ["ScreamURITemplate", "ScreamURITemplateCompilerPlugin"]),
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
            dependencies: ["ScreamURITemplate", "ScreamURITemplateMacros"]),
        .macro(
            name: "ScreamURITemplateCompilerPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "ScreamURITemplate"
            ]
        )
        
    ],
    swiftLanguageVersions: [.v5])
