//   Copyright 2018-2024 Alex Deem
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

/// The value of a URITemplate variable to use during processing
///
/// This type represents the value of a variable, as defined by [RFC6570](https://tools.ietf.org/html/rfc6570), to be used in
/// template processing.
///
/// Variables can be either a string, a list of strings, or an associative array of string key, value pairs.
///
/// While you can process a template by providing variable values using this type (via ``TypedVariableProvider``) you may find it
/// more ergonomic to provide ``VariableValue`` using ``VariableProvider``, or for simple cases simply `[String: String]`
public enum TypedVariableValue {
    /// A simple string value
    case string(String)
    /// An ordered list of strings
    case list([String])
    /// An associative array of string key, value pairs
    ///
    /// Note that the elements are ordered
    case associativeArray([(key: String, value: String)])
}

/// A protocol enabling ergonomic expression of variable values
///
/// Conforming a type to this protocol will enable it to be directly provided as a variable value via ``VariableProvider``
public protocol VariableValue {
    /// Converts this value to a TypedVariableValue to be used for template processing
    func asTypedVariableValue() -> TypedVariableValue?
}

/// A protocol enabling ergonomic expression of simple string variable values
///
/// Conforming a type to this protocol will enable it to be directly provided as a variable value, or as an element in a list or
/// associative array value via ``VariableProvider``
public protocol StringVariableValue: VariableValue {
    /// Converts this value to a `String` to be used for template processing
    func asString() -> String
}

public extension StringVariableValue {
    /// Converts this value to a TypedVariableValue to be used for template processing
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
    /// Converts this value to a `String` to be used for template processing
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
