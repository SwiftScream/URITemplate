//   Copyright 2018 Alex Deem
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

internal protocol Component {
    func expand(variables: [String:VariableValue]) throws -> String
    var variableNames : [String] { get }
}

extension Component {
    var variableNames : [String] {
        return []
    }
}

internal struct LiteralComponent : Component {
    let literal: Substring
    init (_ string: Substring) {
        literal = string
    }

    func expand(variables _: [String:VariableValue]) throws -> String {
        let expansion = String(literal)
        guard let encodedExpansion = expansion.addingPercentEncoding(withAllowedCharacters: reservedAndUnreservedCharacterSet) else {
            throw URITemplate.Error.expansionFailure(position: literal.startIndex, reason: "Percent Encoding Failed")
        }
        return encodedExpansion;
    }
}

internal struct LiteralPercentEncodedTripletComponent : Component {
    let literal: Substring
    init (_ string: Substring) {
        literal = string
    }

    func expand(variables _: [String:VariableValue]) throws -> String {
        return String(literal)
    }
}

internal struct ExpressionComponent : Component {
    let expressionOperator: ExpressionOperator
    let variableList: [VariableSpec]
    let templatePosition: String.Index

    init (expressionOperator: ExpressionOperator, variableList: [VariableSpec], templatePosition: String.Index) {
        self.expressionOperator = expressionOperator
        self.variableList = variableList
        self.templatePosition = templatePosition
    }

    func expand(variables: [String:VariableValue]) throws -> String {
        let configuration = expressionOperator.expansionConfiguration()
        let expansions = try variableList.compactMap { variableSpec -> String? in
            guard let value = variables[String(variableSpec.name)] else {
                return nil;
            }
            do {
                if let stringValue = value as? String {
                    return try stringValue.formatForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
                } else if let arrayValue = value as? [String] {
                    switch variableSpec.modifier {
                    case .prefix:
                        throw FormatError.failure(reason: "Prefix operator can only be applied to string")
                    case .explode:
                        return try arrayValue.explodeForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
                    case .none:
                        return try arrayValue.formatForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
                    }
                } else if let dictionaryValue = value as? [String:String] {
                    switch variableSpec.modifier {
                    case .prefix:
                        throw FormatError.failure(reason: "Prefix operator can only be applied to string")
                    case .explode:
                        return try dictionaryValue.explodeForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
                    case .none:
                        return try dictionaryValue.formatForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
                    }
                } else {
                    throw FormatError.failure(reason: "Invalid Value Type")
                }
            } catch FormatError.failure(let reason) {
                throw URITemplate.Error.expansionFailure(position: templatePosition, reason: "Failed expanding variable \"\(variableSpec.name)\": \(reason)")
            }
        }

        if (expansions.count == 0) {
            return ""
        }

        let joinedExpansions = expansions.joined(separator:configuration.separator)
        if let prefix = configuration.prefix {
            return prefix + joinedExpansions
        }
        return joinedExpansions;
    }

    var variableNames : [String] {
        return variableList.map { variableSpec in
            return String(variableSpec.name)
        }
    }
}
