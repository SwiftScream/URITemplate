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

/// A type that provides variable values to use in template processing
///
/// This type provides values using ``VariableValue`` which allows for an ergonomic way to provide values.
public protocol VariableProvider {
    /// Get the ``VariableValue`` for a given variable
    ///
    /// - Parameters:
    ///   - : the name of the variable
    /// - Returns: the ``VariableValue`` for the variable, or `nil` if the variable has no value
    subscript(_: String) -> VariableValue? { get }
}

/// A type that provides variable values to use in template processing
///
/// This type provides values using ``TypedVariableValue``
///
/// Consider using ``VariableProvider`` for a more ergonomic way of providing variable values.
public protocol TypedVariableProvider {
    /// Get the ``TypedVariableValue`` for a given variable
    ///
    /// - Parameters:
    ///   - : the name of the variable
    ///
    /// - Returns: the ``TypedVariableValue`` for the variable, or `nil` if the variable has no value
    subscript(_: String) -> TypedVariableValue? { get }
}

/// A typealias for the most simple ``VariableProvider`` implementation: `[String: VariableValue]`
public typealias VariableDictionary = [String: VariableValue]

extension VariableDictionary: VariableProvider {}

/// A typealias for the most simple ``TypedVariableProvider`` implementation: `[String: TypedVariableValue]`
public typealias TypedVariableDictionary = [String: TypedVariableValue]

extension TypedVariableDictionary: TypedVariableProvider {}

/// An object that aggregates a `Sequence` of ``VariableProvider`` as a single ``VariableProvider``
///
/// This object allows using a prioritised sequence of VariableProvider as a single VariableProvider.
/// The first VariableProvider in the sequence that provides a value for a given variable name is the value that is returned.
public struct SequenceVariableProvider: VariableProvider, ExpressibleByArrayLiteral {
    let sequence: any Sequence<VariableProvider>

    public init(sequence: any Sequence<VariableProvider>) {
        self.sequence = sequence
    }

    public init(arrayLiteral elements: VariableProvider...) {
        self.init(sequence: elements)
    }

    public subscript(_ name: String) -> VariableValue? {
        for provider in sequence {
            if let value = provider[name] {
                return value
            }
        }
        return nil
    }
}
