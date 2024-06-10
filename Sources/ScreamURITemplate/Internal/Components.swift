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

typealias ComponentBase = Sendable

protocol Component: ComponentBase {
    func expand(variables: VariableProvider) throws -> String
    var variableNames: [String] { get }
}

extension Component {
    var variableNames: [String] {
        return []
    }
}

struct LiteralComponent: Component {
    let literal: Substring
    init(_ string: Substring) {
        literal = string
    }

    func expand(variables _: VariableProvider) throws -> String {
        let expansion = String(literal)
        guard let encodedExpansion = expansion.addingPercentEncoding(withAllowedCharacters: reservedAndUnreservedCharacterSet) else {
            throw URITemplate.Error.expansionFailure(position: literal.startIndex, reason: "Percent Encoding Failed")
        }
        return encodedExpansion
    }
}

struct LiteralPercentEncodedTripletComponent: Component {
    let literal: Substring
    init(_ string: Substring) {
        literal = string
    }

    func expand(variables _: VariableProvider) throws -> String {
        return String(literal)
    }
}

struct ExpressionComponent: Component {
    let expressionOperator: ExpressionOperator
    let variableList: [VariableSpec]
    let templatePosition: String.Index

    init(expressionOperator: ExpressionOperator, variableList: [VariableSpec], templatePosition: String.Index) {
        self.expressionOperator = expressionOperator
        self.variableList = variableList
        self.templatePosition = templatePosition
    }

    func expand(variables: VariableProvider) throws -> String {
        let configuration = expressionOperator.expansionConfiguration()
        let expansions = try variableList.compactMap { variableSpec -> String? in
            guard let value = variables[String(variableSpec.name)]?.asTypedVariableValue() else {
                return nil
            }
            do {
                return try value.formatForTemplateExpansion(variableSpec: variableSpec, expansionConfiguration: configuration)
            } catch let FormatError.failure(reason) {
                throw URITemplate.Error.expansionFailure(position: templatePosition, reason: "Failed expanding variable \"\(variableSpec.name)\": \(reason)")
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

    var variableNames: [String] {
        return variableList.map { variableSpec in
            return String(variableSpec.name)
        }
    }
}
