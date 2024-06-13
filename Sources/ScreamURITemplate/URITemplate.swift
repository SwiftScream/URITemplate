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

/// An [RFC6570](https://tools.ietf.org/html/rfc6570) URI Template
public struct URITemplate {
    /// An error that may be thrown when parsing or processing a template
    public enum Error: Swift.Error {
        /// Represents an error parsing a string into a URI Template
        case malformedTemplate(position: String.Index, reason: String)
        /// Represents an error processing a template
        case expansionFailure(position: String.Index, reason: String)
    }

    private let string: String
    private let components: [Component]

    /// Initializes a URITemplate from a string
    /// - Parameter string: the string representation of the URI Template
    ///
    /// - Throws: `URITemplate.Error.malformedTemplate` if the string is not a valid URI Template
    public init(string: String) throws {
        var components: [Component] = []
        var scanner = Scanner(string: string)
        while !scanner.isComplete {
            try components.append(scanner.scanComponent())
        }
        self.string = string
        self.components = components
    }

    /// Process a URI Template specifying variables with a ``TypedVariableProvider``
    /// - Parameter variables: A ``TypedVariableProvider`` that can provide values for the template variables
    ///
    /// - Returns: The result of processing the template
    ///
    /// - Throws: `URITemplate.Error.expansionFailure` if an error occurs processing the template
    public func process(variables: TypedVariableProvider) throws -> String {
        var result = ""
        for component in components {
            result += try component.expand(variables: variables)
        }
        return result
    }

    /// Process a URI Template specifying variables with a ``VariableProvider``
    ///
    /// This method allows for specifying variables in a more ergonomic manner compared to using ``TypedVariableValue`` directly
    ///
    /// - Parameter variables: A ``VariableProvider`` that can provide values for the template variables
    ///
    /// - Returns: The result of processing the template
    ///
    /// - Throws: `URITemplate.Error.expansionFailure` if an error occurs processing the template
    public func process(variables: VariableProvider) throws -> String {
        struct TypedVariableProviderWrapper: TypedVariableProvider {
            let variables: VariableProvider

            subscript(_ key: String) -> TypedVariableValue? {
                return variables[key]?.asTypedVariableValue()
            }
        }

        return try process(variables: TypedVariableProviderWrapper(variables: variables))
    }

    /// Process a URI Template where the variable values are all of type string
    ///
    /// This method is an override allowing for the special case of string-only variables without needing to typecast
    ///
    /// - Parameter variables: A [String: String] dictionary representing the variables
    ///
    /// - Returns: The result of processing the template
    ///
    /// - Throws: `URITemplate.Error.expansionFailure` if an error occurs processing the template
    public func process(variables: [String: String]) throws -> String {
        return try process(variables: variables as VariableDictionary)
    }

    /// An array of all variable names used in the template
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
