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

enum FormatError: Error {
    case failure(reason: String)
}

func percentEncode(string: String, withAllowedCharacters allowedCharacterSet: CharacterSet, allowPercentEncodedTriplets: Bool) throws -> String {
    guard var encoded = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else {
        throw FormatError.failure(reason: "Percent Encoding Failed")
    }
    if allowPercentEncodedTriplets {
        // Revert where any percent-encode-triplets had their % encoded (to %25)
        var searchRange = encoded.startIndex..<encoded.endIndex
        while let matchRange = encoded.range(of: "%25", range: searchRange) {
            searchRange = matchRange.upperBound..<encoded.endIndex

            let firstIndex = matchRange.upperBound
            guard firstIndex < encoded.endIndex, encoded[firstIndex].isHexDigit else {
                continue
            }
            let secondIndex = encoded.index(after: firstIndex)
            guard secondIndex < encoded.endIndex, encoded[secondIndex].isHexDigit else {
                continue
            }

            let removeRange = encoded.index(after: matchRange.lowerBound)..<matchRange.upperBound
            encoded.removeSubrange(removeRange)
            searchRange = removeRange.lowerBound..<encoded.endIndex
        }
    }
    return encoded
}

extension StringProtocol {
    func formatForTemplateExpansion(variableSpec: VariableSpec, expansionConfiguration: ExpansionConfiguration) throws -> String {
        let modifiedValue = if let prefixLength = variableSpec.prefixLength() {
            String(prefix(prefixLength))
        } else {
            String(self)
        }
        let encodedExpansion = try percentEncode(string: modifiedValue, withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
        if expansionConfiguration.named {
            if encodedExpansion.isEmpty && expansionConfiguration.omittOrphanedEquals {
                return String(variableSpec.name)
            }
            return "\(variableSpec.name)=\(encodedExpansion)"
        }
        return encodedExpansion
    }
}

extension Array where Element: StringProtocol {
    func formatForTemplateExpansion(variableSpec: VariableSpec, expansionConfiguration: ExpansionConfiguration) throws -> String? {
        let separator = ","
        let encodedExpansions = try map { element -> String in
            return try percentEncode(string: String(element), withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
        }
        if encodedExpansions.count == 0 {
            return nil
        }
        let expansion = encodedExpansions.joined(separator: separator)
        if expansionConfiguration.named {
            if expansion.isEmpty && expansionConfiguration.omittOrphanedEquals {
                return String(variableSpec.name)
            }
            return "\(variableSpec.name)=\(expansion)"
        }
        return expansion
    }

    func explodeForTemplateExpansion(variableSpec: VariableSpec, expansionConfiguration: ExpansionConfiguration) throws -> String? {
        let separator = expansionConfiguration.separator
        let encodedExpansions = try map { element -> String in
            let encodedElement = try percentEncode(string: String(element), withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
            if expansionConfiguration.named {
                if encodedElement.isEmpty && expansionConfiguration.omittOrphanedEquals {
                    return String(variableSpec.name)
                }
                return "\(variableSpec.name)=\(encodedElement)"
            }
            return encodedElement
        }
        if encodedExpansions.count == 0 {
            return nil
        }
        return encodedExpansions.joined(separator: separator)
    }
}

extension Dictionary where Key: StringProtocol, Value: StringProtocol {
    func formatForTemplateExpansion(variableSpec: VariableSpec, expansionConfiguration: ExpansionConfiguration) throws -> String? {
        let encodedExpansions = try map { key, value -> String in
            let encodedKey = try percentEncode(string: String(key), withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
            let encodedValue = try percentEncode(string: String(value), withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
            return "\(encodedKey),\(encodedValue)"
        }
        if encodedExpansions.count == 0 {
            return nil
        }
        let expansion = encodedExpansions.joined(separator: ",")
        if expansionConfiguration.named {
            return "\(variableSpec.name)=\(expansion)"
        }
        return expansion
    }

    func explodeForTemplateExpansion(variableSpec: VariableSpec, expansionConfiguration: ExpansionConfiguration) throws -> String? {
        let separator = expansionConfiguration.separator
        let encodedExpansions = try map { key, value -> String in
            let encodedKey = try percentEncode(string: String(key), withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
            let encodedValue = try percentEncode(string: String(value), withAllowedCharacters: expansionConfiguration.percentEncodingAllowedCharacterSet, allowPercentEncodedTriplets: expansionConfiguration.allowPercentEncodedTriplets)
            if expansionConfiguration.named && encodedValue.isEmpty && expansionConfiguration.omittOrphanedEquals {
                return String(variableSpec.name)
            }
            return "\(encodedKey)=\(encodedValue)"
        }
        if encodedExpansions.count == 0 {
            return nil
        }
        return encodedExpansions.joined(separator: separator)
    }
}
