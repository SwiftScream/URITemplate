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

    class URLByExpandingURITemplateMacroTests: XCTestCase {
        let testMacros: [String: Macro.Type] = [
            "URLByExpandingURITemplate": URLByExpandingURITemplateMacro.self,
        ]

        func testMacroAvailability() {
            let plugin = URITemplateCompilerPlugin()
            XCTAssert(plugin.providingMacros.contains { $0 == URLByExpandingURITemplateMacro.self })
        }

        func testValid() throws {
            assertMacroExpansion(
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    "repo": "URITemplate",
                    "username": "alexdeem",
                ])
                """#,
                expandedSource:
                #"""
                URL(string: "https://api.github.com/repos/SwiftScream/URITemplate/collaborators/alexdeem")!
                """#,
                diagnostics: [],
                macros: testMacros)
        }

        func testInvalidTemplate() throws {
            assertMacroExpansion(
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    "repo": "URITemplate",
                    "username": "alexdeem",
                ])
                """#,
                expandedSource:
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    "repo": "URITemplate",
                    "username": "alexdeem",
                ])
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "Invalid URI template: Empty Variable Name at \"}/{repo}/collaborators/{username}\"", line: 1, column: 28),
                ],
                macros: testMacros)
        }

        func testInvalidURL() throws {
            assertMacroExpansion(
                #"""
                #URLByExpandingURITemplate("{nope}", ["nope": ""])
                """#,
                expandedSource:
                #"""
                #URLByExpandingURITemplate("{nope}", ["nope": ""])
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "Processed template does not form a valid URL\n", line: 1, column: 1),
                ],
                macros: testMacros)
        }

        func testMisusedTemplate() throws {
            assertMacroExpansion(
                #"""
                let s: StaticString = "https://api.github.com/repos/{owner}"
                #URLByExpandingURITemplate(s, [
                    "owner": "SwiftScream",
                ])
                """#,
                expandedSource:
                #"""
                let s: StaticString = "https://api.github.com/repos/{owner}"
                #URLByExpandingURITemplate(s, [
                    "owner": "SwiftScream",
                ])
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "#URLByExpandingURITemplate requires a static string literal for the first argument", line: 2, column: 1),
                ],
                macros: testMacros)
        }

        func testMisusedParams() throws {
            assertMacroExpansion(
                #"""
                let params: KeyValue<StaticString, StaticString> = ["owner": "SwiftScream"]
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", params)
                """#,
                expandedSource:
                #"""
                let params: KeyValue<StaticString, StaticString> = ["owner": "SwiftScream"]
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", params)
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "#URLByExpandingURITemplate requires a Dictionary Literal of string literals for the second argument", line: 2, column: 1),
                ],
                macros: testMacros)
        }

        func testMisusedParamKey() throws {
            assertMacroExpansion(
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    123: "URITemplate",
                    "username": "alexdeem",
                ])
                """#,
                expandedSource:
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    123: "URITemplate",
                    "username": "alexdeem",
                ])
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "#URLByExpandingURITemplate requires a Dictionary Literal of string literals for the second argument", line: 1, column: 1),
                ],
                macros: testMacros)
        }

        func testMisusedParamValue() throws {
            assertMacroExpansion(
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    "repo": 12345,
                    "username": "alexdeem",
                ])
                """#,
                expandedSource:
                #"""
                #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}", [
                    "owner": "SwiftScream",
                    "repo": 12345,
                    "username": "alexdeem",
                ])
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "#URLByExpandingURITemplate requires a Dictionary Literal of string literals for the second argument", line: 1, column: 1),
                ],
                macros: testMacros)
        }
    }
#endif
