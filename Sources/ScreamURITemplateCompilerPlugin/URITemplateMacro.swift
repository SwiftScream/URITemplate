//   Copyright 2018-2024 Alex Deem
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
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

import ScreamURITemplate

public struct URITemplateMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in _: some MacroExpansionContext) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression,
              let uriTemplateString = argument.stringLiteral()
        else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node,
                           message: MacroExpansionErrorMessage("#URITemplate requires a static string literal")),
            ])
        }

        do {
            _ = try URITemplate(string: uriTemplateString)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: argument,
                           message: MacroExpansionErrorMessage("Invalid URI template: \(error.reason) at \"\(uriTemplateString.suffix(from: error.position).prefix(50))\"")),
            ])
        }

        return "try! URITemplate(string: \(argument))"
    }
}
