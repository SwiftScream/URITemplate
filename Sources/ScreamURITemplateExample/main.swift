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
import ScreamURITemplate
import ScreamURITemplateMacros

let template = try URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
let variables = [
    "owner": "SwiftScream",
    "repo": "URITemplate",
    "username": "alexdeem",
]

let urlString = try template.process(variables: variables)

let url = URL(string: urlString)!
print("Expanding \(template)\n     with \(variables):\n")
print(url.absoluteString)

let macroExpansion = #URITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
print(macroExpansion)

let urlExpansion = #URLByExpandingURITemplate("https://api.github.com/repos/{owner}/{repo}/collaborators/{username}",
                                              with: ["owner": "SwiftScream", "repo": "URITemplate", "username": "alexdeem"])
print(urlExpansion)

@VariableProvider
struct GitHubRepoCollaborator {
    let owner: String
    let repo: String
    let username: String
}

let expansion = try macroExpansion.process(variables: GitHubRepoCollaborator(owner: "SwiftScream", repo: "URITemplate", username: "alexdeem"))
print(expansion)

let typedTemplate = TypedURITemplate<GitHubRepoCollaborator>(macroExpansion)
let result = try typedTemplate.process(variables: .init(owner: "SwiftScream", repo: "SwiftScream", username: "alexdeem"))
print(result)
