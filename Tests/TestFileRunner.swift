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

import Foundation
import URITemplate

let maxSupportedLevel = 1

internal class TestFileRunner {

    internal static func runFile(_ filename: String) -> Bool {
        let bundle = Bundle(for: self)
        guard let testURL = bundle.url(forResource: filename, withExtension: "json") else {
            return false
        }

        var successCount = 0
        var failureCount = 0

        let testGroups = parseTestFile(URL: testURL)
        for group in testGroups {
            if group.level ?? 4 > maxSupportedLevel {
                continue
            }

            print(group.name)
            print("  Variables: " + group.variables.description)
            for test in group.testcases {
                let template : URITemplate
                do {
                    template = try URITemplate(string: test.template)
                } catch URITemplate.Error.malformedTemplate(let position, let reason) {
                    let characters = test.template[..<position].count
                    var success = true
                    if (!test.shouldFail) {
                        success = false
                    } else {
                        if (test.failPosition != nil && test.failPosition != characters) {
                            success = false
                        }
                        if (test.failReason != nil && test.failReason != reason) {
                            success = false
                        }
                    }
                    if (success) {
                        print("  ✔ \"\(test.template)\" Failed Parsing at position \(characters) with reason \"\(reason)\"")
                        successCount += 1
                    } else {
                        if (test.shouldFail) {
                            print("  ✘ \"\(test.template)\" Failed Parsing at position \(characters) with reason \"\(reason)\"   Expected: Failure at position: \(test.failPosition ?? -1) with reason \(test.failReason ?? "_")")
                        } else {
                            print("  ✘ \"\(test.template)\" Failed Parsing at position \(characters) with reason \"\(reason)\"   Expected: \"\(test.acceptableExpansions.first!)\"")
                        }
                        failureCount += 1
                    }
                    continue
                } catch {
                    print("  ✘ \"\(test.template)\" Fatal Parsing Failure")
                    failureCount += 1
                    continue
                }

                let result : String
                do {
                    result = try template.process(variables: group.variables)
                } catch URITemplate.Error.expansionFailure(let position, let reason) {
                    let characters = test.template[..<position].count
                    var success = true
                    if (!test.shouldFail) {
                        success = false
                    } else {
                        if (test.failPosition != nil && test.failPosition != characters) {
                            success = false
                        }
                        if (test.failReason != nil && test.failReason != reason) {
                            success = false
                        }
                    }
                    if (success) {
                        print("  ✔ \"\(test.template)\" Failed Expansion at position \(characters) with reason \"\(reason)\"")
                        successCount += 1
                    } else {
                        if (test.shouldFail) {
                            print("  ✘ \"\(test.template)\" Failed Expansion at position \(characters) with reason \"\(reason)\"   Expected: Failure at position: \(test.failPosition ?? -1) with reason \(test.failReason ?? "_")")
                        } else {
                            print("  ✘ \"\(test.template)\" Failed Expansion at position \(characters) with reason \"\(reason)\"   Expected: \"\(test.acceptableExpansions.first!)\"")
                        }
                        failureCount += 1
                    }
                    continue
                } catch {
                    print("  ✘ \"\(test.template)\" Fatal Processing Failure")
                    failureCount += 1
                    continue
                }

                if (test.acceptableExpansions.contains(result)) {
                    print("  ✔ \"\(test.template)\" -> \"\(result)\"")
                    successCount += 1
                } else {
                    if (test.shouldFail) {
                        print("  ✘ \"\(test.template)\" -> \"\(result)\"   Expected: Failure at position: \(test.failPosition ?? -1) with reason \(test.failReason ?? "_")")
                    } else {
                        print("  ✘ \"\(test.template)\" -> \"\(result)\"   Expected: \"\(test.acceptableExpansions.first!)\"")
                    }
                    failureCount += 1
                }
            }
        }

        return failureCount == 0
    }

}
