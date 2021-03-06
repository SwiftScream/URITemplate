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

import UIKit
import Dispatch
import URITemplate

class ViewController: UIViewController {

    override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        self.view = view

        do {
            let template = try URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
            let variables = ["owner": "SwiftScream",
                             "repo": "URITemplate",
                             "username": "alexdeem"]

            let urlString = try template.process(variables: variables)

            let url = URL(string: urlString)!
            print("Expanding \(template)\n     with \(variables):\n")
            print(url.absoluteString)
        } catch URITemplate.Error.malformedTemplate(_, let reason) {
            print("Failed parsing template (\(reason))")
        } catch URITemplate.Error.expansionFailure(_, let reason) {
            print("Failed expanding template (\(reason))")
        } catch {
            print("Unexpected Failure")
        }
    }

}
