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

import Foundation
import ScreamURITemplate

private typealias TestFile = [String: TestGroupDecodable]

private struct TestGroupDecodable: Decodable {
    let level: Int?
    let variables: [String: JSONValue]
    let testcases: [[JSONValue]]
}

public struct TestGroup {
    public let name: String
    public let level: Int?
    public let variables: [String: VariableValue]
    public let testcases: [TestCase]
}

public struct TestCase {
    public let template: String
    public let acceptableExpansions: [String]
    public let shouldFail: Bool
    public let failPosition: Int?
    public let failReason: String?
}

extension JSONValue {
    func toVariableValue() -> VariableValue? {
        switch self {
        case let .int(int):
            return String(int)
        case let .double(double):
            return String(double)
        case let .string(string):
            return string
        case let .object(object):
            return object.mapValues { element -> String? in
                switch element {
                case let .string(string):
                    return string
                default:
                    return nil
                }
            }.filter { $0.value != nil }
                .mapValues { $0! }
        case let .array(array):
            return array.compactMap { element -> String? in
                switch element {
                case let .string(string):
                    return string
                default:
                    return nil
                }
            }
        default:
            return nil
        }
    }
}

extension TestCase {
    // swiftlint:disable:next cyclomatic_complexity
    init?(_ data: [JSONValue]) {
        if data.count < 2 {
            return nil
        }

        guard let first = data.first, case let .string(template) = first else {
            return nil
        }

        let expansionsData = data[1]
        switch expansionsData {
        case let .string(string):
            // HACK: ensure the tests support alternate ordering for dictionary explode tests
            // A PR has been raised to add support for the alternate ordering https://github.com/uri-templates/uritemplate-test/pull/58
            switch string {
            case "key1,val1%2F,key2,val2%2F":
                acceptableExpansions = [string, "key2,val2%2F,key1,val1%2F"]
            case "#key1,val1%2F,key2,val2%2F":
                acceptableExpansions = [string, "#key2,val2%2F,key1,val1%2F"]
            case "key1,val1%252F,key2,val2%252F":
                acceptableExpansions = [string, "key2,val2%252F,key1,val1%252F"]
            default:
                acceptableExpansions = [string]
            }
            shouldFail = false
        case let .array(array):
            acceptableExpansions = array.compactMap { value in
                switch value {
                case let .string(string):
                    return string
                default:
                    return nil
                }
            }
            shouldFail = false
        case .bool, .int, .double, .object, .null:
            acceptableExpansions = []
            shouldFail = true
        }

        self.template = template

        var failPosition: Int?
        if data.count > 2 {
            if case let .int(position) = data[2] {
                failPosition = position
            }
        }

        var failReason: String?
        if data.count > 3 {
            if case let .string(reason) = data[3] {
                failReason = reason
            }
        }

        self.failPosition = failPosition
        self.failReason = failReason
    }
}

public func parseTestFile(URL: URL) -> [TestGroup]? {
    guard let testData = try? Data(contentsOf: URL),
          let testCollection = try? JSONDecoder().decode(TestFile.self, from: testData) else {
        print("Failed to decode test file \(URL)")
        return nil
    }

    return testCollection.map { testGroupName, testGroupData in
        let variables = testGroupData.variables.mapValues { element in
            return element.toVariableValue()
        }.filter { return $0.value != nil }
            .mapValues { return $0! }

        let testcases = testGroupData.testcases.compactMap { element in
            return TestCase(element)
        }

        return TestGroup(name: testGroupName, level: testGroupData.level, variables: variables, testcases: testcases)
    }
}
