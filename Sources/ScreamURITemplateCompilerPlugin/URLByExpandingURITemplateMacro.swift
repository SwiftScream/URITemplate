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
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

import ScreamURITemplate

public struct URLByExpandingURITemplateMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in _: some MacroExpansionContext) throws -> ExprSyntax {
        guard let templateArgument = node.arguments.first?.expression,
              let uriTemplateString = templateArgument.stringLiteral() else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node,
                           message: MacroExpansionErrorMessage("#URLByExpandingURITemplate requires a static string literal for the first argument")),
            ])
        }

        guard let paramsArgument = node.arguments.last?.expression,
              let params = paramsArgument.dictionaryLiteral() else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node,
                           message: MacroExpansionErrorMessage("#URLByExpandingURITemplate requires a Dictionary Literal of string literals for the second argument")),
            ])
        }

        let template: URITemplate
        do {
            template = try URITemplate(string: uriTemplateString)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: templateArgument,
                           message: MacroExpansionErrorMessage("Invalid URI template: \(error.reason) at \"\(uriTemplateString.suffix(from: error.position).prefix(50))\"")),
            ])
        }

        let processedTemplate: String
        do {
            processedTemplate = try template.process(variables: params)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node,
                           message: MacroExpansionErrorMessage("Failed to process template: \(error.reason)")),
            ])
        }

        guard URL(string: processedTemplate) != nil else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node,
                           message: MacroExpansionErrorMessage("Processed template does not form a valid URL\n\(processedTemplate)")),
            ])
        }

        return "URL(string: \(processedTemplate.makeLiteralSyntax()))!"
    }
}
