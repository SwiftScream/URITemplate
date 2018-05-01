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

internal enum FormatError: Error {
    case failure(reason: String)
}

internal extension StringProtocol {
    internal func formatForTemplateExpansion(variableName: Substring, expansionConfiguration: ExpansionConfiguration) throws -> String {
        let value = String(self)
        guard let encodedExpansion = value.addingPercentEncoding(withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet) else {
            throw FormatError.failure(reason:"Percent Encoding Failed")
        }
        if (expansionConfiguration.named) {
            if (encodedExpansion.isEmpty && expansionConfiguration.omittOrphanedEquals) {
                return String(variableName)
            }
            return "\(variableName)=\(encodedExpansion)"
        }
        return encodedExpansion
    }
}

internal extension Array where Element: StringProtocol {
    internal func formatForTemplateExpansion(variableName: Substring, expansionConfiguration: ExpansionConfiguration) throws -> String? {
        let separator = ","
        let encodedExpansions = try self.map { element -> String in
            guard let encodedElement = String(element).addingPercentEncoding(withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet) else {
                throw FormatError.failure(reason:"Percent Encoding Failed")
            }
            return encodedElement
        }
        if encodedExpansions.count == 0 {
            return nil
        }
        let expansion = encodedExpansions.joined(separator:separator)
        if (expansionConfiguration.named) {
            if (expansion.isEmpty && expansionConfiguration.omittOrphanedEquals) {
                return String(variableName)
            }
            return "\(variableName)=\(expansion)"
        }
        return expansion
    }
}

internal extension Dictionary where Key: StringProtocol, Value: StringProtocol {
    internal func formatForTemplateExpansion(variableName: Substring, expansionConfiguration: ExpansionConfiguration) throws -> String? {
        let encodedExpansions = try self.map { key, value -> String in
            guard let encodedKey = String(key).addingPercentEncoding(withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet) else {
                throw FormatError.failure(reason:"Percent Encoding Failed")
            }
            guard let encodedValue = String(value).addingPercentEncoding(withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet) else {
                throw FormatError.failure(reason:"Percent Encoding Failed")
            }
            return "\(encodedKey),\(encodedValue)"
        }
        if encodedExpansions.count == 0 {
            return nil
        }
        let expansion = encodedExpansions.joined(separator:",")
        if (expansionConfiguration.named) {
            return "\(variableName)=\(expansion)"
        }
        return expansion
    }
}
