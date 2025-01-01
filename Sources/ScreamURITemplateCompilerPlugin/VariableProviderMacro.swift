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

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private class ProviderAttributeDiagnosticVisitor: SyntaxVisitor {
    var macroExpansionContext: MacroExpansionContext?

    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        let attributeName = node.attributeName.trimmedDescription
        if attributeName == "Provided" || attributeName == "ScreamURITemplateMacros.Provided" {
            let diagnostic = Diagnostic(
                node: node,
                message: MacroExpansionErrorMessage("@Provided attribute nested in conditional compilation is not respected; sorry"))
            macroExpansionContext?.diagnose(diagnostic)
        }
        return .visitChildren
    }
}

public struct VariableProviderMacro: ExtensionMacro {
    public static func expansion(
        of _: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        let allVariableDeclarations = declaration.memberBlock.members.compactMap { member -> VariableDeclSyntax? in
            member.decl.as(VariableDeclSyntax.self)
        }
        let explicitlyProvidedVariableDeclarations = allVariableDeclarations.filter { declaration in
            return declaration.attributes.contains { node in
                switch node {
                case let .attribute(attribute):
                    let attributeName = attribute.attributeName.trimmedDescription
                    return attributeName == "Provided" || attributeName == "ScreamURITemplateMacros.Provided"
                case let .ifConfigDecl(node):
                    let visitor = ProviderAttributeDiagnosticVisitor(viewMode: .all)
                    visitor.macroExpansionContext = context
                    visitor.walk(node)
                    return false
                }
            }
        }
        // If no properties are explicitly marked, all proprties are provided
        let declarations = explicitlyProvidedVariableDeclarations.count > 0 ? explicitlyProvidedVariableDeclarations : allVariableDeclarations
        let variableIdentifiers = declarations.compactMap { declaration -> String? in
            declaration.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        }

        return try [
            ExtensionDeclSyntax("extension \(type.trimmed): VariableProvider") {
                """
                subscript(_ v: String) -> VariableValue? {
                    return switch v {
                """
                for variableIdentifiers in variableIdentifiers {
                    """
                        case "\(raw: variableIdentifiers)": \(raw: variableIdentifiers)
                    """
                }
                """

                        default: nil
                        }
                    }
                """
            },
        ]
    }
}
