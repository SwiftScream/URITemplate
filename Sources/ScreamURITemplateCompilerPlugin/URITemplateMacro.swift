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

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

import ScreamURITemplate

/// ASDTODO: Documentation
public struct URITemplateMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression,
              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case .stringSegment(let literalSegment)? = segments.first
        else {
          throw CustomError.message("#URITemplate requires a static string literal")
        }

        let uriTemplateString = literalSegment.content.text
        do {
            let _ = try URITemplate(string: uriTemplateString)
        } catch URITemplate.Error.malformedTemplate(let errorPosition, let reason) {
            let offset = errorPosition.utf16Offset(in: uriTemplateString)
            throw CustomError.message("Invalid URITemplate; \(reason) at offset \(offset)")
        } catch {
            throw CustomError.message("Invalid URITemplate")
        }

        return "try! URITemplate(string: \(argument))"
    }
}
