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

public struct URITemplate {
    public enum Error : Swift.Error {
        case malformedTemplate(position: String.Index, reason: String)
        case expansionFailure(position: String.Index, reason: String)
    }

    private let components : [Component]

    public init(string: String) throws {
        var components : [Component] = []
        var scanner = Scanner(string: string)
        while !scanner.isComplete {
            try components.append(scanner.scanComponent())
        }
        self.components = components
    }

    public func process(variables: [String:String]) throws -> String {
        var result = ""
        for component in components {
            result += try component.expand(variables:variables)
        }
        return result
    }
}
