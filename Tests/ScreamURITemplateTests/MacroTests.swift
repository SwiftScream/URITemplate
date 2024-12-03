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

#if canImport(ScreamURITemplateCompilerPlugin)
    import ScreamURITemplateCompilerPlugin

    import SwiftSyntaxMacros
    import SwiftSyntaxMacrosTestSupport

    import XCTest

    class MacroTests: XCTestCase {
        let testMacros: [String: Macro.Type] = [
            "URITemplate": URITemplateMacro.self,
        ]

        func testValidURITemplateMacro() throws {
            assertMacroExpansion(
                #"""
                #URITemplate("https://api.github.com/repos/{owner}")
                """#,
                expandedSource:
                #"""
                try! URITemplate(string: "https://api.github.com/repos/{owner}")
                """#,
                diagnostics: [],
                macros: testMacros)
        }

        func testInvalidURITemplateMacro() throws {
            assertMacroExpansion(
                #"""
                #URITemplate("https://api.github.com/repos/{}/{repo}")
                """#,
                expandedSource:
                #"""
                #URITemplate("https://api.github.com/repos/{}/{repo}")
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "Invalid URI template: Empty Variable Name at \"}/{repo}\"", line: 1, column: 15),
                ],
                macros: testMacros)
        }

        func testMisusedURITemplateMacro() throws {
            assertMacroExpansion(
                #"""
                let s: StaticString = "https://api.github.com/repos/{owner}"
                #URITemplate(s)
                """#,
                expandedSource:
                #"""
                let s: StaticString = "https://api.github.com/repos/{owner}"
                #URITemplate(s)
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "#URITemplate requires a static string literal", line: 2, column: 1),
                ],
                macros: testMacros)
        }
    }
#endif
