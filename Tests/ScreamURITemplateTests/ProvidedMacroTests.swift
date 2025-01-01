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

    class ProvidedMacroTests: XCTestCase {
        let testMacros: [String: Macro.Type] = [
            "Provided": ProvidedMacro.self,
        ]

        func testMacroAvailability() {
            let plugin = URITemplateCompilerPlugin()
            XCTAssert(plugin.providingMacros.contains { $0 == ProvidedMacro.self })
        }

        func testNoCodeGenerated() throws {
            assertMacroExpansion(
                #"""
                struct A {
                    @Provided let owner: String
                    @Provided let repo: String
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
                """#,
                diagnostics: [],
                macros: testMacros)
        }
    }
#endif
