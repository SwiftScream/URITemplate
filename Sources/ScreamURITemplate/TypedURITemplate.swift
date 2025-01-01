//   Copyright 2018-2025 Alex Deem
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

/// A wrapper around a ``URITemplate`` that limits the type of the variables provided when processing
/// This can be used to provide a strongly-typed interface for processing a template
public struct TypedURITemplate<Variables: VariableProvider> {
    private let template: URITemplate

    /// Initializes a ``TypedURITemplate`` from a ``URITemplate``
    /// - Parameter template: the URI Template
    public init(_ template: URITemplate) {
        self.template = template
    }

    /// Process a URI Template specifying variables with an instance of the templated type `Variables`
    /// - Parameter variables: A ``Variables`` object that can provide values for the template variables
    ///
    /// - Returns: The result of processing the template
    ///
    /// - Throws: `URITemplate.Error` with `type = .expansionFailure` if an error occurs processing the template
    public func process(variables: Variables) throws(URITemplate.Error) -> String {
        try template.process(variables: variables)
    }
}
