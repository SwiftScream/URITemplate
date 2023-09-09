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

let unreservedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
private let genDelimsCharacterSet = CharacterSet(charactersIn: ":/?#[]@")
private let subDelimsCharacterSet = CharacterSet(charactersIn: "!$&'()*+,;=")
let reservedCharacterSet = genDelimsCharacterSet.union(subDelimsCharacterSet)
let reservedAndUnreservedCharacterSet = reservedCharacterSet.union(unreservedCharacterSet)
let invertedLiteralCharacterSet = CharacterSet.illegalCharacters.union(CharacterSet.controlCharacters).union(CharacterSet(charactersIn: " \"%<>\\^`{|}"))
let literalCharacterSet = invertedLiteralCharacterSet.inverted
let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
let varnameCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_%."))
let invertedVarnameCharacterSet = varnameCharacterSet.inverted
let expressionOperatorCharacterSet = CharacterSet(charactersIn: "+#./;?&=,!@|")
let invertedDecimalDigitsCharacterSet = CharacterSet.decimalDigits.inverted
