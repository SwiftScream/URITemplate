//   Copyright 2018-2026 Alex Deem
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

private struct Benchmark {
    let name: String
    let template: String
}

private let benchmarks = [
    Benchmark(
        name: "typical",
        template: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"),
    Benchmark(
        name: "operators",
        template: "https://example.com{/segments*}{?query,limit,filters*}{#fragment}"),
    Benchmark(
        name: "unicode-literal",
        template: "https://example.com/café/東京/{category}/{identifier}"),
    Benchmark(
        name: "long-literal",
        template: "https://example.com/" + String(repeating: "path-segment/", count: 20) + "{value}"),
    Benchmark(
        name: "many-components",
        template: String(repeating: "literal-{value}", count: 10)),
    Benchmark(
        name: "many-variables",
        template: "{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t}"),
    Benchmark(
        name: "many-percent-triplets",
        template: String(repeating: "%20", count: 40) + "{value}"),
]

private let iterations = CommandLine.arguments.dropFirst().first.flatMap(Int.init) ?? 200_000
private let samples = 7

private func measure(_ benchmark: Benchmark) throws -> Duration {
    var durations: [Duration] = []

    for _ in 0..<samples {
        let clock = ContinuousClock()
        let start = clock.now
        for _ in 0..<iterations {
            _ = try URITemplate(string: benchmark.template)
        }
        durations.append(start.duration(to: clock.now))
    }

    durations.sort()
    let median = durations[durations.count / 2]
    return median / iterations
}

print("iterations: \(iterations), samples: \(samples)")
for benchmark in benchmarks {
    let result = try measure(benchmark)
    let components = result.components
    let microseconds = Double(components.seconds) * 1_000_000
        + Double(components.attoseconds) / 1_000_000_000_000
    let millisecondsPerThousand = microseconds
    print("\(benchmark.name): \(String(format: "%.3f", millisecondsPerThousand)) ms / thousand iterations")
}
