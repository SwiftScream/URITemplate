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

class TestFileTests: XCTestCase {
    private var templateString: String!
    private var variables: [String: VariableValue]!
    private var acceptableExpansions: [String]!
    private var failPosition: Int?
    private var failReason: String?

    func testFileParseFailed() {
        XCTFail("Test File Parse Failed")
    }

    func testSuccessfulProcess() throws {
        let template = try URITemplate(string: templateString)
        let result = try template.process(variables: variables)
        XCTAssertTrue(acceptableExpansions.contains(result))
    }

    func testFailedProcess() {
        do {
            let template = try URITemplate(string: templateString)
            _ = try template.process(variables: variables)
            XCTFail("Did not throw")
        } catch let URITemplate.Error.malformedTemplate(position, reason) {
            if failReason != nil {
                XCTAssertEqual(failReason, reason)
            }
            if failPosition != nil {
                let characters = templateString[..<position].count
                XCTAssertEqual(failPosition, characters)
            }
        } catch let URITemplate.Error.expansionFailure(position, reason) {
            if failReason != nil {
                XCTAssertEqual(failReason, reason)
            }
            if failPosition != nil {
                let characters = templateString[..<position].count
                XCTAssertEqual(failPosition, characters)
            }
        } catch {
            XCTFail("Threw an unexpected error")
        }
    }

    override class var defaultTestSuite: XCTestSuite {
        let parentTestSuite = XCTestSuite(name: "TestFileTests")
        parentTestSuite.addTest(testSuiteForTestFile("tests"))
        parentTestSuite.addTest(testSuiteForTestFile("spec-examples"))
        parentTestSuite.addTest(testSuiteForTestFile("spec-examples-by-section"))
        parentTestSuite.addTest(testSuiteForTestFile("extended-tests"))
        parentTestSuite.addTest(testSuiteForTestFile("negative-tests"))
        return parentTestSuite
    }

    private class func testSuiteForTestFile(_ filename: String) -> XCTestSuite {
        let fileTestSuite = XCTestSuite(name: "File: \(filename).json")

        guard let testURL = Bundle.module.url(forResource: filename, withExtension: "json") else {
            fileTestSuite.addTest(TestFileTests(selector: #selector(TestFileTests.testFileParseFailed)))
            return fileTestSuite
        }

        guard let testGroups = parseTestFile(URL: testURL) else {
            fileTestSuite.addTest(TestFileTests(selector: #selector(TestFileTests.testFileParseFailed)))
            return fileTestSuite
        }
        for group in testGroups {
            let groupTestSuite = XCTestSuite(name: "Group: \(group.name)")
            for test in group.testcases {
                if test.shouldFail {
                    let testCase = TestFileTests(selector: #selector(TestFileTests.testFailedProcess))
                    testCase.templateString = test.template
                    testCase.variables = group.variables
                    testCase.failPosition = test.failPosition
                    testCase.failReason = test.failReason
                    groupTestSuite.addTest(testCase)
                } else {
                    let testCase = TestFileTests(selector: #selector(TestFileTests.testSuccessfulProcess))
                    testCase.templateString = test.template
                    testCase.variables = group.variables
                    testCase.acceptableExpansions = test.acceptableExpansions
                    groupTestSuite.addTest(testCase)
                }
            }
            fileTestSuite.addTest(groupTestSuite)
        }

        return fileTestSuite
    }
}
