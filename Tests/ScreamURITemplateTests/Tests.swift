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

class Tests: XCTestCase {
    #if swift(>=5.5)
        func testSendable() {
            let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
            let sendable = template as Sendable
            XCTAssertNotNil(sendable)
        }
    #endif

    func testCustomStringConvertible() {
        let template: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        XCTAssertEqual(template.description, "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
    }

    func testExpressibleByStringLiteral() {
        let templateA: URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        guard let templateB = try? URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}") else {
            XCTFail("invalid template")
            return
        }
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

    func testEncoding() {
        do {
            let templateString = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
            let template = try URITemplate(string: templateString)
            let jsonData = try JSONEncoder().encode(["a": template])
            let expectedData = try JSONEncoder().encode(["a": templateString])
            XCTAssertEqual(jsonData, expectedData)
        } catch {
            XCTFail("unexpected throw")
        }
    }

    func testDecoding() {
        do {
            let templateString = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
            let jsonString = "{\"a\":\"\(templateString)\"}"
            let jsonData = jsonString.data(using: .utf8)!
            let object = try JSONDecoder().decode([String: URITemplate].self, from: jsonData)
            let expectedTemplate = try URITemplate(string: templateString)
            XCTAssertEqual(object["a"], expectedTemplate)
        } catch {
            XCTFail("unexpected throw")
        }
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
