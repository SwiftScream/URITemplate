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

#if canImport(ScreamURITemplateCompilerPlugin)
    @testable import ScreamURITemplateCompilerPlugin

    import SwiftSyntaxMacros
    import SwiftSyntaxMacrosTestSupport

    import XCTest

    class VariableProviderMacroTests: XCTestCase {
        let testMacros: [String: Macro.Type] = [
            "VariableProvider": VariableProviderMacro.self,
        ]

        func testMacroAvailability() {
            let plugin = URITemplateCompilerPlugin()
            XCTAssert(plugin.providingMacros.contains { $0 == VariableProviderMacro.self })
        }

        func testEmpty() throws {
            assertMacroExpansion(
                #"""
                @VariableProvider
                struct A {
                }
                """#,
                expandedSource:
                #"""
                struct A {
                }

                extension A: VariableProvider {
                    subscript(_ v: String) -> VariableValue? {
                        return switch v {
                        default: nil
                        }
                    }
                }
                """#,
                diagnostics: [],
                macros: testMacros)
        }

        func testDefaultAllProvided() throws {
            assertMacroExpansion(
                #"""
                @VariableProvider
                struct A {
                    let owner: String
                    let repo: String
                    let username: String
                }
                """#,
                expandedSource:
                #"""
                struct A {
                    let owner: String
                    let repo: String
                    let username: String
                }

                extension A: VariableProvider {
                    subscript(_ v: String) -> VariableValue? {
                        return switch v {
                        case "owner": owner
                        case "repo": repo
                        case "username": username
                        default: nil
                        }
                    }
                }
                """#,
                diagnostics: [],
                macros: testMacros)
        }

        func testExplicitlyProvided() throws {
            assertMacroExpansion(
                #"""
                @VariableProvider
                struct A {
                    @Provided let owner: String
                    @Provided let repo: String
                    let username: String
                }
                """#,
                expandedSource:
                #"""
                struct A {
                    @Provided let owner: String
                    @Provided let repo: String
                    let username: String
                }

                extension A: VariableProvider {
                    subscript(_ v: String) -> VariableValue? {
                        return switch v {
                        case "owner": owner
                        case "repo": repo
                        default: nil
                        }
                    }
                }
                """#,
                diagnostics: [],
                macros: testMacros)
        }

        func testNestedInConditionalCompilation() throws {
            assertMacroExpansion(
                #"""
                @VariableProvider
                struct A {
                    #if true
                    @Provided
                    #endif
                    let owner: String
                    @Provided let repo: String
                }
                """#,
                expandedSource:
                #"""
                struct A {
                    let owner: String
                    @Provided let repo: String
                }

                extension A: VariableProvider {
                    subscript(_ v: String) -> VariableValue? {
                        return switch v {
                        case "repo": repo
                        default: nil
                        }
                    }
                }
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "@Provided attribute nested in conditional compilation is not respected; sorry", line: 4, column: 5),
                ],
                macros: testMacros)
        }

        func testDisambiguatedExplicitlyProvided() throws {
            assertMacroExpansion(
                #"""
                @VariableProvider
                struct A {
                    @ScreamURITemplateMacros.Provided let owner: String
                    @ScreamURITemplateMacros.Provided let repo: String
                    let username: String
                }
                """#,
                expandedSource:
                #"""
                struct A {
                    @ScreamURITemplateMacros.Provided let owner: String
                    @ScreamURITemplateMacros.Provided let repo: String
                    let username: String
                }

                extension A: VariableProvider {
                    subscript(_ v: String) -> VariableValue? {
                        return switch v {
                        case "owner": owner
                        case "repo": repo
                        default: nil
                        }
                    }
                }
                """#,
                diagnostics: [],
                macros: testMacros)
        }
    }
#endif
