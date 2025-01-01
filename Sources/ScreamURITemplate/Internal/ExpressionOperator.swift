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

import Foundation

enum ExpressionOperator: Unicode.Scalar {
    case simple = "\0"
    case reserved = "+"
    case fragment = "#"
    case label = "."
    case pathSegment = "/"
    case pathStyle = ";"
    case query = "?"
    case queryContinuation = "&"

    // swiftlint:disable:next function_body_length
    func expansionConfiguration() -> ExpansionConfiguration {
        switch self {
        case .simple:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: unreservedCharacterSet,
                                          allowPercentEncodedTriplets: false,
                                          prefix: nil,
                                          separator: ",",
                                          named: false,
                                          omitOrphanedEquals: false)
        case .reserved:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: reservedAndUnreservedCharacterSet,
                                          allowPercentEncodedTriplets: true,
                                          prefix: nil,
                                          separator: ",",
                                          named: false,
                                          omitOrphanedEquals: false)
        case .fragment:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: reservedAndUnreservedCharacterSet,
                                          allowPercentEncodedTriplets: true,
                                          prefix: "#",
                                          separator: ",",
                                          named: false,
                                          omitOrphanedEquals: false)
        case .label:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: unreservedCharacterSet,
                                          allowPercentEncodedTriplets: false,
                                          prefix: ".",
                                          separator: ".",
                                          named: false,
                                          omitOrphanedEquals: false)
        case .pathSegment:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: unreservedCharacterSet,
                                          allowPercentEncodedTriplets: false,
                                          prefix: "/",
                                          separator: "/",
                                          named: false,
                                          omitOrphanedEquals: false)
        case .pathStyle:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: unreservedCharacterSet,
                                          allowPercentEncodedTriplets: false,
                                          prefix: ";",
                                          separator: ";",
                                          named: true,
                                          omitOrphanedEquals: true)
        case .query:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: unreservedCharacterSet,
                                          allowPercentEncodedTriplets: false,
                                          prefix: "?",
                                          separator: "&",
                                          named: true,
                                          omitOrphanedEquals: false)
        case .queryContinuation:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet: unreservedCharacterSet,
                                          allowPercentEncodedTriplets: false,
                                          prefix: "&",
                                          separator: "&",
                                          named: true,
                                          omitOrphanedEquals: false)
        }
    }
}
