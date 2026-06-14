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

struct Scanner {
    let string: String
    let utf8: String.UTF8View
    let unicodeScalars: String.UnicodeScalarView
    var currentIndex: String.Index

    init(string: String) {
        self.string = string
        utf8 = string.utf8
        unicodeScalars = string.unicodeScalars
        currentIndex = string.startIndex
    }

    var isComplete: Bool {
        return currentIndex >= utf8.endIndex
    }

    mutating func scanComponent() throws(URITemplate.Error) -> Component {
        let nextByte = utf8[currentIndex]

        switch nextByte {
        case UTF8.CodeUnit.openBrace:
            return try scanExpressionComponent()
        case UTF8.CodeUnit.percent:
            return try scanPercentEncodingComponent()
        default:
            return try scanLiteralComponent()
        }
    }

    private mutating func scanExpressionComponent() throws(URITemplate.Error) -> Component {
        assert(utf8[currentIndex] == UTF8.CodeUnit.openBrace)
        let expressionStartIndex = currentIndex
        currentIndex = utf8.index(after: currentIndex)

        let expressionOperator = try scanExpressionOperator()
        let variableList = try scanVariableList()

        return .expression(
            ExpressionComponent(
                expressionOperator: expressionOperator,
                variableList: variableList,
                templatePosition: expressionStartIndex))
    }

    private mutating func scanExpressionOperator() throws(URITemplate.Error) -> ExpressionOperator {
        guard currentIndex < utf8.endIndex else {
            return .simple
        }

        let expressionOperator: ExpressionOperator
        switch utf8[currentIndex] {
        case UTF8.CodeUnit.plus:
            expressionOperator = .reserved
        case UTF8.CodeUnit.hash:
            expressionOperator = .fragment
        case UTF8.CodeUnit.period:
            expressionOperator = .label
        case UTF8.CodeUnit.slash:
            expressionOperator = .pathSegment
        case UTF8.CodeUnit.semicolon:
            expressionOperator = .pathStyle
        case UTF8.CodeUnit.questionMark:
            expressionOperator = .query
        case UTF8.CodeUnit.ampersand:
            expressionOperator = .queryContinuation
        case UTF8.CodeUnit.equals, UTF8.CodeUnit.comma, UTF8.CodeUnit.exclamation, UTF8.CodeUnit.at, UTF8.CodeUnit.pipe:
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unsupported Operator")
        default:
            return .simple
        }
        currentIndex = utf8.index(after: currentIndex)
        return expressionOperator
    }

    private mutating func scanVariableList() throws(URITemplate.Error) -> [VariableSpec] {
        var variableList: [VariableSpec] = []

        var complete = false
        while !complete {
            let variableName = try scanVariableName()
            let modifier = try scanVariableModifier()
            variableList.append(VariableSpec(name: variableName, modifier: modifier))

            guard currentIndex < utf8.endIndex else {
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unterminated Expression")
            }

            switch utf8[currentIndex] {
            case UTF8.CodeUnit.comma:
                currentIndex = utf8.index(after: currentIndex)
            case UTF8.CodeUnit.closeBrace:
                currentIndex = utf8.index(after: currentIndex)
                complete = true
            default:
                throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unexpected Character in Expression")
            }
        }

        return variableList
    }

    private mutating func scanVariableName() throws(URITemplate.Error) -> Substring {
        let startIndex = currentIndex
        var index = currentIndex
        var requiresVariableCharacter = true

        while index < utf8.endIndex {
            let byte = utf8[index]

            if byte.isUnencodedVariableNameCharacter() {
                requiresVariableCharacter = false
                index = utf8.index(after: index)
                continue
            }

            if byte == .percent {
                let firstHexIndex = utf8.index(after: index)
                guard firstHexIndex < utf8.endIndex else {
                    throw URITemplate.Error(type: .malformedTemplate, position: startIndex, reason: "% must be percent-encoded in variable name")
                }
                let secondHexIndex = utf8.index(after: firstHexIndex)
                guard secondHexIndex < utf8.endIndex,
                      utf8[firstHexIndex].isHexDigit(),
                      utf8[secondHexIndex].isHexDigit() else {
                    throw URITemplate.Error(type: .malformedTemplate, position: startIndex, reason: "% must be percent-encoded in variable name")
                }
                requiresVariableCharacter = false
                index = utf8.index(after: secondHexIndex)
                continue
            }

            if byte == .period {
                guard !requiresVariableCharacter else {
                    if index == startIndex {
                        throw URITemplate.Error(type: .malformedTemplate, position: index, reason: "Variable Name Cannot Begin With '.'")
                    }
                    throw URITemplate.Error(type: .malformedTemplate, position: index, reason: "Variable name cannot contain consecutive period characters")
                }
                requiresVariableCharacter = true
                index = utf8.index(after: index)
                continue
            }

            break
        }

        if index == startIndex {
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Empty Variable Name")
        }
        if requiresVariableCharacter {
            throw URITemplate.Error(type: .malformedTemplate, position: utf8.index(before: index), reason: "Variable name cannot end with '.'")
        }

        currentIndex = index
        return string[startIndex..<index]
    }

    private mutating func scanVariableModifier() throws(URITemplate.Error) -> VariableSpec.Modifier {
        guard currentIndex < utf8.endIndex else {
            return .none
        }

        switch utf8[currentIndex] {
        case UTF8.CodeUnit.asterisk:
            currentIndex = utf8.index(after: currentIndex)
            return .explode
        case UTF8.CodeUnit.colon:
            currentIndex = utf8.index(after: currentIndex)
            let endIndex = scanWhile { $0.isDecimalDigit() }
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
        let startIndex = currentIndex
        var endIndex = currentIndex
        while endIndex < utf8.endIndex {
            let byte = utf8[endIndex]

            if byte.isASCII() {
                guard byte.isAllowedInLiteral() else {
                    break
                }
                endIndex = utf8.index(after: endIndex)
            } else {
                guard unicodeScalars[endIndex].isAllowedInLiteral() else {
                    break
                }
                endIndex = unicodeScalars.index(after: endIndex)
            }
        }
        currentIndex = endIndex

        if startIndex == endIndex {
            throw URITemplate.Error(type: .malformedTemplate, position: currentIndex, reason: "Unexpected character")
        }

        return .literal(LiteralComponent(string[startIndex..<endIndex]))
    }

    private mutating func scanPercentEncodingComponent() throws(URITemplate.Error) -> Component {
        assert(utf8[currentIndex] == UTF8.CodeUnit.percent)

        let startIndex = currentIndex
        var endIndex = startIndex

        while endIndex < utf8.endIndex, utf8[endIndex] == UTF8.CodeUnit.percent {
            let secondIndex = utf8.index(after: endIndex)
            guard secondIndex < utf8.endIndex else {
                throw URITemplate.Error(type: .malformedTemplate, position: endIndex, reason: "% must be percent-encoded in literal")
            }

            let thirdIndex = utf8.index(after: secondIndex)
            guard thirdIndex < utf8.endIndex else {
                throw URITemplate.Error(type: .malformedTemplate, position: endIndex, reason: "% must be percent-encoded in literal")
            }

            guard utf8[secondIndex].isHexDigit(),
                  utf8[thirdIndex].isHexDigit() else {
                throw URITemplate.Error(type: .malformedTemplate, position: endIndex, reason: "% must be percent-encoded in literal")
            }

            endIndex = utf8.index(after: thirdIndex)
        }

        currentIndex = endIndex
        return .percentEncodedLiteral(LiteralPercentEncodedComponent(string[startIndex..<endIndex]))
    }

    private func scanWhile(_ predicate: (UTF8.CodeUnit) -> Bool) -> String.Index {
        var index = currentIndex
        while index < utf8.endIndex, predicate(utf8[index]) {
            index = utf8.index(after: index)
        }
        return index
    }
}

private extension UTF8.CodeUnit {
    static let exclamation: UTF8.CodeUnit = 0x21
    static let doubleQuote: UTF8.CodeUnit = 0x22
    static let hash: UTF8.CodeUnit = 0x23
    static let percent: UTF8.CodeUnit = 0x25
    static let ampersand: UTF8.CodeUnit = 0x26
    static let asterisk: UTF8.CodeUnit = 0x2A
    static let plus: UTF8.CodeUnit = 0x2B
    static let comma: UTF8.CodeUnit = 0x2C
    static let period: UTF8.CodeUnit = 0x2E
    static let slash: UTF8.CodeUnit = 0x2F
    static let zero: UTF8.CodeUnit = 0x30
    static let nine: UTF8.CodeUnit = 0x39
    static let colon: UTF8.CodeUnit = 0x3A
    static let semicolon: UTF8.CodeUnit = 0x3B
    static let lessThan: UTF8.CodeUnit = 0x3C
    static let equals: UTF8.CodeUnit = 0x3D
    static let greaterThan: UTF8.CodeUnit = 0x3E
    static let questionMark: UTF8.CodeUnit = 0x3F
    static let backslash: UTF8.CodeUnit = 0x5C
    static let caret: UTF8.CodeUnit = 0x5E
    static let underscore: UTF8.CodeUnit = 0x5F
    static let backtick: UTF8.CodeUnit = 0x60
    static let openBrace: UTF8.CodeUnit = 0x7B
    static let pipe: UTF8.CodeUnit = 0x7C
    static let closeBrace: UTF8.CodeUnit = 0x7D
    // swiftlint:disable identifier_name
    static let at: UTF8.CodeUnit = 0x40
    static let A: UTF8.CodeUnit = 0x41
    static let F: UTF8.CodeUnit = 0x46
    static let Z: UTF8.CodeUnit = 0x5A
    static let a: UTF8.CodeUnit = 0x61
    static let f: UTF8.CodeUnit = 0x66
    static let z: UTF8.CodeUnit = 0x7A
    // swiftlint:enable identifier_name

    func isASCII() -> Bool {
        self < 0x80
    }

    func isDecimalDigit() -> Bool {
        self >= .zero && self <= .nine
    }

    func isHexDigit() -> Bool {
        (self >= .zero && self <= .nine) ||
            (self >= .A && self <= .F) ||
            (self >= .a && self <= .f)
    }

    func isUnencodedVariableNameCharacter() -> Bool {
        (self >= .zero && self <= .nine) ||
            (self >= .A && self <= .Z) ||
            (self >= .a && self <= .z) ||
            self == .underscore
    }

    func isAllowedInLiteral() -> Bool {
        (self > 0x20 && self < 0x7F) &&
            self != .doubleQuote &&
            self != .percent &&
            self != .lessThan &&
            self != .greaterThan &&
            self != .backslash &&
            self != .caret &&
            self != .backtick &&
            self != .openBrace &&
            self != .pipe &&
            self != .closeBrace
    }
}

private extension Unicode.Scalar {
    func isAllowedInLiteral() -> Bool {
        switch value {
        case 0xA0...0xD7FF,
             0xF900...0xFDCF,
             0xFDF0...0xFFEF,
             0x10000...0x1FFFD,
             0x20000...0x2FFFD,
             0x30000...0x3FFFD,
             0x40000...0x4FFFD,
             0x50000...0x5FFFD,
             0x60000...0x6FFFD,
             0x70000...0x7FFFD,
             0x80000...0x8FFFD,
             0x90000...0x9FFFD,
             0xA0000...0xAFFFD,
             0xB0000...0xBFFFD,
             0xC0000...0xCFFFD,
             0xD0000...0xDFFFD,
             0xE1000...0xEFFFD,
             0xE000...0xF8FF,
             0xF0000...0xFFFFD,
             0x100000...0x10FFFD:
            true
        default:
            false
        }
    }
}
