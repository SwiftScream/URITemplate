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

public enum TypedVariableValue {
    case string(String)
    case list([String])
    case associativeArray([(key: String, value: String)])
}

public protocol VariableValue {
    func asTypedVariableValue() -> TypedVariableValue?
}

public protocol StringVariableValue: VariableValue {
    func asString() -> String
}

public extension StringVariableValue {
    func asTypedVariableValue() -> TypedVariableValue? {
        .string(asString())
    }
}

extension [StringVariableValue]: VariableValue {
    public func asTypedVariableValue() -> TypedVariableValue? {
        .list(map { $0.asString() })
    }
}

extension KeyValuePairs<String, StringVariableValue>: VariableValue {
    public func asTypedVariableValue() -> TypedVariableValue? {
        .associativeArray(map { ($0, $1.asString()) })
    }
}

extension [String: StringVariableValue]: VariableValue {
    public func asTypedVariableValue() -> TypedVariableValue? {
        .associativeArray(map { ($0, $1.asString()) }.sorted { $0.0 < $1.0 })
    }
}

public extension LosslessStringConvertible {
    func asString() -> String {
        description
    }
}

extension String: StringVariableValue {}
extension Bool: StringVariableValue {}
extension Character: StringVariableValue {}
extension Double: StringVariableValue {}
extension Float: StringVariableValue {}
extension Int: StringVariableValue {}
extension Int16: StringVariableValue {}
extension Int32: StringVariableValue {}
extension Int64: StringVariableValue {}
extension Int8: StringVariableValue {}
extension Substring: StringVariableValue {}
extension UInt: StringVariableValue {}
extension UInt16: StringVariableValue {}
extension UInt32: StringVariableValue {}
extension UInt64: StringVariableValue {}
extension UInt8: StringVariableValue {}
extension Unicode.Scalar: StringVariableValue {}

extension UUID: StringVariableValue {
    public func asString() -> String {
        uuidString
    }
}
