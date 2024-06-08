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

import ScreamURITemplate
import XCTest

struct TestVariableProvider: VariableProvider {
    subscript(_ key: String) -> VariableValue? {
        return "_\(key)_"
    }
}

class Tests: XCTestCase {
    func testVariableProvider() throws {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let urlString = try template.process(variables: TestVariableProvider())
        XCTAssertEqual(urlString, "https://api.github.com/repos/_owner_/_repo_/collaborators/_username_")
    }

    func testStringStringDictionary() throws {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let variables = ["owner": "SwiftScream",
                         "repo": "URITemplate",
                         "username": "alexdeem"]
        let urlString = try template.process(variables: variables)
        XCTAssertEqual(urlString, "https://api.github.com/repos/SwiftScream/URITemplate/collaborators/alexdeem")
    }

    func testVariableDictionaryPlain() throws {
        let template: URITemplate = "https://api.example.com/{string}/{int}/{bool}"
        let variables: VariableDictionary = [
            "string": "SwiftScream",
            "int": 42,
            "bool": true,
        ]
        let urlString = try template.process(variables: variables)
        XCTAssertEqual(urlString, "https://api.example.com/SwiftScream/42/true")
    }

    func testVariableDictionaryList() throws {
        let template: URITemplate = "https://api.example.com/{list}"
        let variables: VariableDictionary = [
            "list": ["SwiftScream", 42, true],
        ]
        let urlString = try template.process(variables: variables)
        XCTAssertEqual(urlString, "https://api.example.com/SwiftScream,42,true")
    }

    func testVariableDictionaryAssocList() throws {
        let template: URITemplate = "https://api.example.com/path{?unordered*,ordered*}"
        let variables: VariableDictionary = [
            "unordered": [
                "b": 42,
                "a": "A",
                "c": true,
            ],
            "ordered": [
                "b2": 42,
                "a2": "A",
                "c2": true,
            ] as KeyValuePairs,
        ]
        let urlString = try template.process(variables: variables)
        XCTAssertTrue([
            "https://api.example.com/path?a=A&b=42&c=true&b2=42&a2=A&c2=true",
            "https://api.example.com/path?a=A&c=true&b=42&b2=42&a2=A&c2=true",
            "https://api.example.com/path?b=42&a=A&c=true&b2=42&a2=A&c2=true",
            "https://api.example.com/path?b=42&c=true&a=A&b2=42&a2=A&c2=true",
            "https://api.example.com/path?c=true&a=A&b=42&b2=42&a2=A&c2=true",
            "https://api.example.com/path?c=true&b=42&a=A&b2=42&a2=A&c2=true",
        ].contains(urlString))
    }

    func testUUIDVariable() throws {
        let template: URITemplate = "https://api.example.com/{id}"
        let variables: VariableDictionary = [
            "id": UUID(uuidString: "1740A1A9-B3AD-4AE9-954B-918CEDE95285")!,
        ]
        let urlString = try template.process(variables: variables)
        XCTAssertEqual(urlString, "https://api.example.com/1740A1A9-B3AD-4AE9-954B-918CEDE95285")
    }

    func testSendable() {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let sendable = template as Sendable
        XCTAssertNotNil(sendable)
    }

    func testCustomStringConvertible() {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        XCTAssertEqual(template.description, "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
    }

    func testExpressibleByStringLiteral() throws {
        let templateA: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let templateB = try URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        XCTAssertEqual(templateA, templateB)
    }

    func testEquatable() {
        let templateA: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let templateB: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        XCTAssertEqual(templateA, templateB)
        let templateC: URITemplate = "https://api.github.com/repos/{owner}"
        XCTAssertNotEqual(templateB, templateC)
        let templateD = templateC
        XCTAssertEqual(templateC, templateD)
        XCTAssertEqual(templateC, templateC)
    }

    func testHashable() {
        let templateA: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let templateB: URITemplate = "https://api.github.com/repos/{owner}"
        let dictionary = [templateA: "A", templateB: "B"]
        XCTAssertEqual(dictionary[templateA], "A")
        XCTAssertEqual(dictionary[templateB], "B")
    }

    func testHashableHashValue() {
        let templateA1: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let templateA2: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let templateB1: URITemplate = "https://api.github.com/repos/{owner}"
        let templateB2: URITemplate = "https://api.github.com/repos/{owner}"
        XCTAssertEqual(templateA1.hashValue, templateA2.hashValue)
        XCTAssertEqual(templateB1.hashValue, templateB2.hashValue)
    }

    func testVariableNames() {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let variableNames = template.variableNames
        let expected = ["owner", "repo", "username"]
        XCTAssertEqual(variableNames, expected)
    }

    func testEncoding() throws {
        let templateString = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let template = try URITemplate(string: templateString)
        let jsonData = try JSONEncoder().encode(["a": template])
        let expectedData = try JSONEncoder().encode(["a": templateString])
        XCTAssertEqual(jsonData, expectedData)
    }

    func testDecoding() throws {
        let templateString = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let jsonString = "{\"a\":\"\(templateString)\"}"
        let jsonData = jsonString.data(using: .utf8)!
        let object = try JSONDecoder().decode([String: URITemplate].self, from: jsonData)
        let expectedTemplate = try URITemplate(string: templateString)
        XCTAssertEqual(object["a"], expectedTemplate)
    }

    func testInitPerformance() {
        measure {
            for _ in 1...5000 {
                _ = try? URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
            }
        }
    }

    func testProcessPerformance() {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let variables = ["owner": "SwiftScream",
                         "repo": "URITemplate",
                         "username": "alexdeem"]

        measure {
            for _ in 1...5000 {
                _ = try? template.process(variables: variables)
            }
        }
    }
}
