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
    func expand(variables: [String:String]) throws -> String
}

internal struct LiteralComponent : Component {
    let literal: Substring
    init (_ string: Substring) {
        literal = string
    }

    func expand(variables _: [String:String]) throws -> String {
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

    func expand(variables _: [String:String]) throws -> String {
        return String(literal)
    }
}

internal struct ExpressionComponent : Component {
    let expressionOperator: ExpressionOperator
    let variable: Substring
    let templatePosition: String.Index

    init (expressionOperator: ExpressionOperator, variable: Substring, templatePosition: String.Index) {
        self.expressionOperator = expressionOperator
        self.variable = variable
        self.templatePosition = templatePosition
    }

    func expand(variables: [String:String]) throws -> String {
        let configuration = expressionOperator.expansionConfiguration()
        let variableName = String(variable)
        let expansion = variables[variableName] ?? ""
        guard let encodedExpansion = expansion.addingPercentEncoding(withAllowedCharacters: configuration.percentEncodingAllowedCharacterSet) else {
            throw URITemplate.Error.expansionFailure(position: templatePosition, reason: "Failed expanding variable \"\(variableName)\": Percent Encoding Failed")
        }
        if let prefix = configuration.prefix {
            return prefix + encodedExpansion
        }
        return encodedExpansion;
    }
}
