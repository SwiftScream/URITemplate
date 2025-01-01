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

import XCTest

import ScreamURITemplate

private struct TestVariableProvider: VariableProvider {
    subscript(_ key: String) -> VariableValue? {
        return "_\(key)_"
    }
}

class TypedURITemplateTests: XCTestCase {
    func testExpansion() throws {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let typedTemplate = TypedURITemplate<TestVariableProvider>(template)
        let urlString = try typedTemplate.process(variables: .init())
        XCTAssertEqual(urlString, "https://api.github.com/repos/_owner_/_repo_/collaborators/_username_")
    }
}
