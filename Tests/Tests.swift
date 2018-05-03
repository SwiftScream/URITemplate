//   Copyright 2018 Alex Deem
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
import URITemplate

class Tests: XCTestCase {
    
    func testCustom() {
        XCTAssert(TestFileRunner.runFile("tests"))
    }

    func testSpecExamples() {
        XCTAssert(TestFileRunner.runFile("spec-examples"))
    }

    func testSpecExamplesBySection() {
        XCTAssert(TestFileRunner.runFile("spec-examples-by-section"))
    }

    func testExtendedTests() {
        XCTAssert(TestFileRunner.runFile("extended-tests"))
    }

    func testNegativeTests() {
        XCTAssert(TestFileRunner.runFile("negative-tests"))
    }

    func testCustomStringConvertible() {
        let template = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        XCTAssertEqual(template.description, "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
    }

    func testExpressibleByStringLiteral() {
        let templateA : URITemplate = "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"
        let templateB = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        XCTAssertEqual(templateA, templateB)
    }

    func testEquatable() {
        let templateA = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        let templateB = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        XCTAssertEqual(templateA, templateB)
        let templateC = try! URITemplate(string: "https://api.github.com/repos/{owner}")
        XCTAssertNotEqual(templateB, templateC)
        let templateD = templateC
        XCTAssertEqual(templateC, templateD)
        XCTAssertEqual(templateC, templateC)
    }

    func testHashable() {
        let templateA = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        let templateB = try! URITemplate(string: "https://api.github.com/repos/{owner}")
        let dictionary = [templateA : "A", templateB : "B"]
        XCTAssertEqual(dictionary[templateA], "A")
        XCTAssertEqual(dictionary[templateB], "B")
    }

    func testVariableNames() {
        let template = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        let variableNames = template.variableNames
        let expected = ["owner", "repo", "username"]
        XCTAssertEqual(variableNames, expected)
    }

    func testInitPerformance() {
        self.measure {
            for _ in 1...5000 {
                _ = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
            }
        }
    }

    func testProcessPerformance() {
        let template = try! URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
        let variables = ["owner": "SwiftScream",
                         "repo": "URITemplate",
                         "username": "alexdeem"]

        self.measure {
            for _ in 1...5000 {
                _ = try! template.process(variables: variables)
            }
        }
    }

}
