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

internal enum ExpressionOperator : Unicode.Scalar {
    case simple = "\0"
    case reserved = "+"
    case fragment = "#"

    func expansionConfiguration() -> ExpansionConfiguration {
        switch self {
        case .simple:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet:unreservedCharacterSet,
                                          prefix:nil,
                                          separator:",")
        case .reserved:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet:reservedAndUnreservedCharacterSet,
                                          prefix:nil,
                                          separator:",")
        case .fragment:
            return ExpansionConfiguration(percentEncodingAllowedCharacterSet:reservedAndUnreservedCharacterSet,
                                          prefix:"#",
                                          separator:",")
        }
    }
}
