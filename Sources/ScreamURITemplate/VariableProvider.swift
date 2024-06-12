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

public protocol VariableProvider {
    subscript(_: String) -> VariableValue? { get }
}

public protocol TypedVariableProvider {
    subscript(_: String) -> TypedVariableValue? { get }
}

public typealias VariableDictionary = [String: VariableValue]

extension VariableDictionary: VariableProvider {}

public typealias TypedVariableDictionary = [String: TypedVariableValue]

extension TypedVariableDictionary: TypedVariableProvider {}

public struct SequenceVariableProvider: VariableProvider, ExpressibleByArrayLiteral {
    let sequence: any Sequence<VariableProvider>

    public init(arrayLiteral elements: VariableProvider...) {
        sequence = elements
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
