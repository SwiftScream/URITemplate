//   Copyright 2018-2023 Alex Deem
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

import Foundation

public struct URITemplate {
    public enum Error: Swift.Error {
        case malformedTemplate(position: String.Index, reason: String)
        case expansionFailure(position: String.Index, reason: String)
    }

    private let string: String
    private let components: [Component]

    public init(string: String) throws {
        var components: [Component] = []
        var scanner = Scanner(string: string)
        while !scanner.isComplete {
            try components.append(scanner.scanComponent())
        }
        self.string = string
        self.components = components
    }

    public func process(variables: TypedVariableProvider) throws -> String {
        var result = ""
        for component in components {
            result += try component.expand(variables: variables)
        }
        return result
    }

    public func process(variables: VariableProvider) throws -> String {
        struct TypedVariableProviderWrapper: TypedVariableProvider {
            let variables: VariableProvider

            subscript(_ key: String) -> TypedVariableValue? {
                return variables[key]?.asTypedVariableValue()
            }
        }

        return try process(variables: TypedVariableProviderWrapper(variables: variables))
    }

    public func process(variables: [String: String]) throws -> String {
        return try process(variables: variables as VariableDictionary)
    }

    public var variableNames: [String] {
        return components.flatMap { component in
            return component.variableNames
        }
    }
}

extension URITemplate: Sendable {}

extension URITemplate: CustomStringConvertible {
    public var description: String {
        return string
    }
}

extension URITemplate: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        // swiftlint:disable:next force_try
        try! self.init(string: "\(value)")
    }
}

extension URITemplate: Equatable {
    public static func == (lhs: URITemplate, rhs: URITemplate) -> Bool {
        return lhs.string == rhs.string
    }
}

extension URITemplate: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}

extension URITemplate: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
