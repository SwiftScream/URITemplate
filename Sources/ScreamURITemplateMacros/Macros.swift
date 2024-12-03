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

import ScreamURITemplate

/// Macro providing compile-time validation of a URITemplate represented by a string literal
/// Example:
/// ```swift
/// let template = #URITemplate("https://api.github.com/repos/{owner}")
/// ```
/// - Parameters:
///   - : A string literal representing the URI Template
/// - Returns: A `URITemplate` constructed from the string literal
@freestanding(expression)
public macro URITemplate(_ stringLiteral: StaticString) -> URITemplate = #externalMacro(module: "ScreamURITemplateCompilerPlugin", type: "URITemplateMacro")
