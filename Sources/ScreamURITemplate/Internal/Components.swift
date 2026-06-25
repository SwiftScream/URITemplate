//   Copyright 2018-2025 Alex Deem
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

enum Component {
    case literal(LiteralComponent)
    case percentEncodedLiteral(LiteralPercentEncodedComponent)
    case expression(ExpressionComponent)

    func expand(variables: TypedVariableProvider) throws(URITemplate.Error) -> String {
        switch self {
        case let .literal(component):
            try component.expand(variables: variables)
        case let .percentEncodedLiteral(component):
            try component.expand(variables: variables)
        case let .expression(component):
            try component.expand(variables: variables)
        }
    }

    var variableNames: [String] {
        switch self {
        case .literal, .percentEncodedLiteral:
            []
        case let .expression(component):
            component.variableNames
        }
    }

    var level: URITemplate.Level {
        switch self {
        case .literal, .percentEncodedLiteral:
            .level1
        case let .expression(component):
            component.level
        }
    }
}

struct LiteralComponent {
    let literal: Substring
    init(_ string: Substring) {
        literal = string
    }

    func expand(variables _: TypedVariableProvider) throws(URITemplate.Error) -> String {
        let expansion = String(literal)
        guard let encodedExpansion = expansion.addingPercentEncoding(withAllowedCharacters: reservedAndUnreservedCharacterSet) else {
            throw URITemplate.Error(type: .expansionFailure, position: literal.startIndex, reason: "Percent Encoding Failed")
        }
        return encodedExpansion
    }
}

struct LiteralPercentEncodedComponent {
    let literal: Substring
    init(_ string: Substring) {
        literal = string
    }

    func expand(variables _: TypedVariableProvider) throws(URITemplate.Error) -> String {
        return String(literal)
    }
}

struct ExpressionComponent {
    let expressionOperator: ExpressionOperator
    let variableList: VariableList
    let templatePosition: String.Index

    func expand(variables: TypedVariableProvider) throws(URITemplate.Error) -> String {
        let configuration = expressionOperator.expansionConfiguration()
        func expansion(for variableSpec: VariableSpec) throws(URITemplate.Error) -> String? {
            guard let value = variables[String(variableSpec.name)] else {
                return nil
            }
            do throws(FormatError) {
                return try value.formatForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
            } catch {
                throw URITemplate.Error(type: .expansionFailure, position: templatePosition, reason: "Failed expanding variable \"\(variableSpec.name)\": \(error.reason)")
            }
        }

        switch variableList {
        case let .one(variableSpec):
            guard let expansion = try expansion(for: variableSpec) else {
                return ""
            }
            if let prefix = configuration.prefix {
                return prefix + expansion
            }
            return expansion
        case let .many(variableSpecs):
            var expansions: [String] = []
            expansions.reserveCapacity(variableSpecs.count)
            for variableSpec in variableSpecs {
                if let expansion = try expansion(for: variableSpec) {
                    expansions.append(expansion)
                }
            }

            if expansions.count == 0 {
                return ""
            }

            let joinedExpansions = expansions.joined(separator: configuration.separator)
            if let prefix = configuration.prefix {
                return prefix + joinedExpansions
            }
            return joinedExpansions
        }
    }

    var variableNames: [String] {
        switch variableList {
        case let .one(variableSpec):
            return [String(variableSpec.name)]
        case let .many(variableSpecs):
            return variableSpecs.map { variableSpec in
                return String(variableSpec.name)
            }
        }
    }

    var level: URITemplate.Level {
        // Check for modifiers (level 4)
        switch variableList {
        case let .one(variableSpec):
            switch variableSpec.modifier {
            case .none:
                break
            case .explode, .prefix:
                return .level4
            }
        case let .many(variableSpecs):
            for variableSpec in variableSpecs {
                switch variableSpec.modifier {
                case .none:
                    continue
                case .explode, .prefix:
                    return .level4
                }
            }
        }

        // Check for multiple variables (level 3)
        if case .many = variableList {
            return .level3
        }

        // Check operators
        return switch expressionOperator {
        case .simple:
            .level1
        case .reserved, .fragment:
            .level2
        case .label, .pathSegment, .pathStyle, .query, .queryContinuation:
            .level3
        }
    }
}
