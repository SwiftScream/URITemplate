# URITemplate [![license](https://img.shields.io/github/license/SwiftScream/URITemplate.svg)](https://raw.githubusercontent.com/SwiftScream/URITemplate/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/SwiftScream/URITemplate.svg)](https://github.com/SwiftScream/URITemplate/releases/latest)


[![Travis](https://api.travis-ci.com/SwiftScream/URITemplate.svg?branch=master)](https://travis-ci.com/SwiftScream/URITemplate)
[![Codecov branch](https://img.shields.io/codecov/c/github/SwiftScream/URITemplate/master.svg)](https://codecov.io/gh/SwiftScream/URITemplate/branch/master)

![Swift 4.1](https://img.shields.io/badge/swift-4.1-4BC51D.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/ScreamURITemplate)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

A robust and performant Swift 4.1 implementation of [RFC6570](https://tools.ietf.org/html/rfc6570) URI Template.  Full Level 4 support is provided.

## Getting Started

### Manual
Static Framework targets are provided for iOS, MacOS, tvOS, and watchOS; integrate them as you normally would.

### CocoaPods
Add `pod 'ScreamURITemplate', '~> 2.0'` to your Podfile

### Carthage
Add `github "SwiftScream/URITemplate" ~> 2.0` to your Cartfile

### Swift Package Manager
Add `.package(url: "https://github.com/SwiftScream/URITemplate.git", from: "2.0.0")` to your package.swift dependencies

## Usage

### Template Processing

```swift
let template = try URITemplate(string:"https://api.github.com/repos/{owner}/{repository}/traffic/views")
let variables = ["owner":"SwiftScream", "repository":"URITemplate"]
let urlString = try template.process(variables)
// https://api.github.com/repos/SwiftScream/URITemplate/traffic/views
```

#### When Things Go Wrong
Both template initialization and processing can fail; throwing a `URITemplate.Error`
The error cases contain associated values specifying a string reason for the error and the index into the template string that the error occurred.

```swift
do {
    _ = try URITemplate(string: "https://api.github.com/repos/{}/{repository}")
} catch URITemplate.Error.malformedTemplate(let position, let reason) {
    // reason = "Empty Variable Name"
    // position = 29th character
}
```

### Get variable names used in a template

```swift
let template = try URITemplate(string:"https://api.github.com/repos/{owner}/{repository}/traffic/views")
let variableNames = template.variableNames
// ["owner", "repository"]
```

### Codable Support
`URITemplate` implements the `Codable` protocol, enabling easy serialization to or from JSON objects.

```swift
struct HALObject : Codable {
    let _links : [String:URITemplate]
}
```

## Tests
The library is tested against the [standard test suite](https://github.com/uri-templates/uritemplate-test), as well as some additional tests for behavior specific to this implementation. It is intended to keep test coverage as high as possible.