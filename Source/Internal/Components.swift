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
    let variableList: [Substring]
    let templatePosition: String.Index

    init (expressionOperator: ExpressionOperator, variableList: [Substring], templatePosition: String.Index) {
        self.expressionOperator = expressionOperator
        self.variableList = variableList
        self.templatePosition = templatePosition
    }

    func expand(variables: [String:VariableValue]) throws -> String {
        let configuration = expressionOperator.expansionConfiguration()
        let expansions = try variableList.compactMap { variableName -> String? in
            guard let value = variables[String(variableName)] else {
                return nil;
            }
            do {
                if let stringValue = value as? String {
                    return try stringValue.formatForTemplateExpansion(variableName: variableName, expansionConfiguration: configuration)
                } else if let arrayValue = value as? [String] {
                    return try arrayValue.formatForTemplateExpansion(variableName: variableName, expansionConfiguration: configuration)
                } else if let dictionaryValue = value as? [String:String] {
                    return try dictionaryValue.formatForTemplateExpansion(variableName: variableName, expansionConfiguration: configuration)
                } else {
                    throw FormatError.failure(reason: "Invalid Value Type")
                }
            } catch FormatError.failure(let reason) {
                throw URITemplate.Error.expansionFailure(position: templatePosition, reason: "Failed expanding variable \"\(variableName)\": \(reason)")
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
}
