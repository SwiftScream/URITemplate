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

import SwiftSyntax

extension ExprSyntax {
    func stringLiteral() -> String? {
        guard let segments = self.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case let .stringSegment(literalSegment)? = segments.first else {
            return nil
        }

        return literalSegment.content.text
    }

    func dictionaryLiteral() -> [String: String]? {
        guard let elements = self.as(DictionaryExprSyntax.self)?.content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        var result: [String: String] = [:]
        for element in elements {
            guard let key = element.key.stringLiteral(),
                  let value = element.value.stringLiteral() else {
                return nil
            }
            result[key] = value
        }

        return result
    }
}
