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

private func ~= (lhs: CharacterSet, rhs: Unicode.Scalar) -> Bool {
    return lhs.contains(rhs)
}

struct Scanner {
    let string: String
    let unicodeScalars: String.UnicodeScalarView
    var currentIndex: String.Index

    init(string: String) {
        self.string = string
        unicodeScalars = string.unicodeScalars
        currentIndex = string.startIndex
    }

    var isComplete: Bool {
        return currentIndex >= unicodeScalars.endIndex
    }

    mutating func scanComponent() throws(URITemplate.Error) -> Component {
        let nextScalar = unicodeScalars[currentIndex]

        switch nextScalar {
        case "{":
            return try scanExpressionComponent()
        case "%":
            return try scanPercentEncodingComponent()
        case literalCharacterSet:
            return try scanLiteralComponent()
        default:
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unexpected character")
        }
    }

    private mutating func scanExpressionComponent() throws(URITemplate.Error) -> Component {
        assert(unicodeScalars[currentIndex] == "{")
        let expressionStartIndex = currentIndex
        currentIndex = unicodeScalars.index(after: currentIndex)

        let expressionOperator = try scanExpressionOperator()
        let variableList = try scanVariableList()

        return ExpressionComponent(expressionOperator: expressionOperator, variableList: variableList, templatePosition: expressionStartIndex)
    }

    private mutating func scanExpressionOperator() throws(URITemplate.Error) -> ExpressionOperator {
        let expressionOperator: ExpressionOperator
        if expressionOperatorCharacterSet.contains(unicodeScalars[currentIndex]) {
            guard let `operator` = ExpressionOperator(rawValue: unicodeScalars[currentIndex]) else {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unsupported Operator")
            }
            expressionOperator = `operator`
            currentIndex = unicodeScalars.index(after: currentIndex)
        } else {
            expressionOperator = .simple
        }
        return expressionOperator
    }

    private mutating func scanVariableList() throws(URITemplate.Error) -> [VariableSpec] {
        var variableList: [VariableSpec] = []

        var complete = false
        while !complete {
            let variableName = try scanVariableName()

            if currentIndex == unicodeScalars.endIndex {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unterminated Expression")
            }

            let modifier = try scanVariableModifier()

            if currentIndex == unicodeScalars.endIndex {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unterminated Expression")
            }

            variableList.append(VariableSpec(name: variableName, modifier: modifier))

            switch unicodeScalars[currentIndex] {
            case ",":
                currentIndex = unicodeScalars.index(after: currentIndex)
            case "}":
                currentIndex = unicodeScalars.index(after: currentIndex)
                complete = true
            default:
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unexpected Character in Expression")
            }
        }

        return variableList
    }

    private mutating func scanVariableName() throws(URITemplate.Error) -> Substring {
        let endIndex = scanUpTo(characterSet: invertedVarnameCharacterSet)
        let variableName = string[currentIndex..<endIndex]
        if variableName.isEmpty {
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Empty Variable Name")
        } else if variableName.starts(with: ".") {
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Variable Name Cannot Begin With '.'")
        }
        var remainingVariableName = variableName
        while let index = remainingVariableName.firstIndex(of: "%") {
            let secondIndex = remainingVariableName.index(after: index)
            let thirdIndex = remainingVariableName.index(after: secondIndex)
            if !hexCharacterSet.contains(unicodeScalars[secondIndex]) ||
                !hexCharacterSet.contains(unicodeScalars[thirdIndex]) {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "% must be percent-encoded in variable name")
            }
            let nextIndex = remainingVariableName.index(after: thirdIndex)
            remainingVariableName = remainingVariableName[nextIndex...]
        }
        currentIndex = endIndex
        return variableName
    }

    private mutating func scanVariableModifier() throws(URITemplate.Error) -> VariableSpec.Modifier {
        switch unicodeScalars[currentIndex] {
        case "*":
            currentIndex = unicodeScalars.index(after: currentIndex)
            return .explode
        case ":":
            currentIndex = unicodeScalars.index(after: currentIndex)
            let endIndex = scanUpTo(characterSet: invertedDecimalDigitsCharacterSet)
            let lengthString = string[currentIndex..<endIndex]
            if lengthString.isEmpty {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Prefix length not specified")
            }
            if lengthString.first == "0" {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Prefix length cannot begin with 0")
            }
            if lengthString.count > 4 {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Prefix modifier length too large")
            }
            guard let length = Int(lengthString) else {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Cannot parse prefix modifier length")
            }
            currentIndex = endIndex
            return .prefix(length: length)
        default:
            return .none
        }
    }

    private mutating func scanLiteralComponent() throws(URITemplate.Error) -> Component {
        assert(literalCharacterSet.contains(unicodeScalars[currentIndex]))

        let startIndex = currentIndex
        let endIndex = scanUpTo(characterSet: invertedLiteralCharacterSet)
        currentIndex = endIndex
        return LiteralComponent(string[startIndex..<endIndex])
    }

    private mutating func scanPercentEncodingComponent() throws(URITemplate.Error) -> Component {
        assert(unicodeScalars[currentIndex] == "%")

        let startIndex = currentIndex
        let secondIndex = unicodeScalars.index(after: startIndex)
        let thirdIndex = unicodeScalars.index(after: secondIndex)

        if !hexCharacterSet.contains(unicodeScalars[secondIndex]) ||
            !hexCharacterSet.contains(unicodeScalars[thirdIndex]) {
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "% must be percent-encoded in literal")
        }

        currentIndex = unicodeScalars.index(after: thirdIndex)
        return LiteralPercentEncodedTripletComponent(string[startIndex...thirdIndex])
    }

    private func scanUpTo(characterSet: CharacterSet) -> String.Index {
        var index = currentIndex
        while index < unicodeScalars.endIndex {
            let scalar = unicodeScalars[index]
            if characterSet.contains(scalar) {
                break
            }
            index = unicodeScalars.index(after: index)
        }
        return index
    }
}
