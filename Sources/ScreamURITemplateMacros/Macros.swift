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

/// Macro providing compile-time validation and processing of a URITemplate and parameters entirely represented by string literals
/// Example:
/// ```swift
/// let template = #URLByExpandingURITemplate("https://api.github.com/repos/{owner}", with: ["owner": "SwiftScream"])
/// ```
/// - Parameters:
///   - : A string literal representing the URI Template
///   - with: The parameters to use to process the template, represented by a dictionary literal where the keys and values are all string literals
/// - Returns: A `URL` constructed from the result of processing the template with the parameters
@freestanding(expression)
public macro URLByExpandingURITemplate(_ stringLiteral: StaticString, with: KeyValuePairs<StaticString, StaticString>) -> URL = #externalMacro(module: "ScreamURITemplateCompilerPlugin", type: "URLByExpandingURITemplateMacro")

/// Macro to provide a default implementation of the `VariableProvider` protocol
/// Example:
/// ```swift
/// @VariableProvider
/// struct GitHubRepo {
///     @Provided let owner: String
///     @Provided let repo: String
///     let transient: Int
/// }
/// ```
/// The generated implementation provides variables named as per the properties of the struct or class
/// By default all properties are provided. If this is not desirable, tag the properties to be provided with the `@Provided` attribute
@attached(extension, conformances: VariableProvider, names: named(subscript))
public macro VariableProvider() = #externalMacro(module: "ScreamURITemplateCompilerPlugin", type: "VariableProviderMacro")

/// Macro used to tag properties that should be provided by the `@VariableProvider` macro
/// This macro generates no code, it's just a marker for use by `@VariableProvider`
@attached(peer)
public macro Provided() = #externalMacro(module: "ScreamURITemplateCompilerPlugin", type: "ProvidedMacro")
