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

private enum BenchmarkSelection {
    case parse
    case process
    case all

    init?(_ argument: String) {
        switch argument.lowercased() {
        case "parse", "parsing":
            self = .parse
        case "process", "processing":
            self = .process
        case "all", "both":
            self = .all
        default:
            return nil
        }
    }

    var includesParse: Bool {
        switch self {
        case .parse, .all:
            true
        case .process:
            false
        }
    }

    var includesProcess: Bool {
        switch self {
        case .process, .all:
            true
        case .parse:
            false
        }
    }
}

private struct ParseBenchmark {
    let name: String
    let template: String
}

private struct ProcessBenchmark {
    let name: String
    let process: () throws -> String
}

private struct GitHubVariables: TypedVariableProvider {
    subscript(_ key: String) -> TypedVariableValue? {
        switch key {
        case "owner":
            .string("SwiftScream")
        case "repo":
            .string("URITemplate")
        case "username":
            .string("alexdeem")
        default:
            nil
        }
    }
}

private let parseBenchmarks = [
    ParseBenchmark(
        name: "typical",
        template: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}"),
    ParseBenchmark(
        name: "operators",
        template: "https://example.com{/segments*}{?query,limit,filters*}{#fragment}"),
    ParseBenchmark(
        name: "unicode-literal",
        template: "https://example.com/café/東京/{category}/{identifier}"),
    ParseBenchmark(
        name: "long-literal",
        template: "https://example.com/" + String(repeating: "path-segment/", count: 20) + "{value}"),
    ParseBenchmark(
        name: "many-components",
        template: String(repeating: "literal-{value}", count: 10)),
    ParseBenchmark(
        name: "many-variables",
        template: "{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t}"),
    ParseBenchmark(
        name: "many-percent-triplets",
        template: String(repeating: "%20", count: 40) + "{value}"),
]

// swiftlint:disable:next function_body_length
private func makeProcessBenchmarks() throws -> [ProcessBenchmark] {
    let typicalTemplate = try URITemplate(string: "https://api.github.com/repos/{owner}/{repo}/collaborators/{username}")
    let typicalStringVariables = [
        "owner": "SwiftScream",
        "repo": "URITemplate",
        "username": "alexdeem",
    ]
    let typicalTypedVariables: TypedVariableDictionary = [
        "owner": .string("SwiftScream"),
        "repo": .string("URITemplate"),
        "username": .string("alexdeem"),
    ]
    let typicalProvider = GitHubVariables()

    let operatorsTemplate = try URITemplate(string: "https://example.com{/segments*}{?query,limit,filters*}{#fragment}")
    let operatorsVariables: TypedVariableDictionary = [
        "segments": .list(["users", "alexdeem", "repositories"]),
        "query": .string("uri template"),
        "limit": .string("25"),
        "filters": .associativeArray([
            (key: "language", value: "swift"),
            (key: "sort", value: "updated"),
            (key: "archived", value: "false"),
        ]),
        "fragment": .string("results"),
    ]

    let literalHeavyTemplate = try URITemplate(
        string: "https://example.com/café/東京/" + String(repeating: "path-segment/", count: 30) + "{value}")
    let literalHeavyVariables = ["value": "Grüner Weg"]

    let longOutputTemplate = try URITemplate(string: "https://example.com/{value}")
    let longOutputVariables = [
        "value": String(repeating: "path segment with spaces/", count: 40),
    ]

    let manyComponentsTemplate = try URITemplate(string: String(repeating: "literal-{value}", count: 10))
    let manyComponentsVariables = ["value": "expanded"]

    let manyVariablesTemplate = try URITemplate(string: "{a,b,c,d,e,f,g,h,i,j,k,l,m}")
    let manyVariables: TypedVariableDictionary = [
        "a": .string("a"),
        "b": .string("b"),
        "c": .string("c"),
        "d": .string("d"),
        "e": .string("e"),
        "f": .string("f"),
        "g": .string("g"),
        "h": .string("h"),
        "i": .string("i"),
        "j": .string("j"),
        "k": .string("k"),
        "l": .string("l"),
        "m": .string("m"),
    ]

    let percentTripletsTemplate = try URITemplate(string: String(repeating: "%20", count: 40) + "{value}")
    let percentTripletsVariables = ["value": "expanded"]

    return [
        ProcessBenchmark(name: "common-string-dictionary") {
            try typicalTemplate.process(variables: typicalStringVariables)
        },
        ProcessBenchmark(name: "common-typed-dictionary") {
            try typicalTemplate.process(variables: typicalTypedVariables)
        },
        ProcessBenchmark(name: "common-typed-provider") {
            try typicalTemplate.process(variables: typicalProvider)
        },
        ProcessBenchmark(name: "operators-composite-values") {
            try operatorsTemplate.process(variables: operatorsVariables)
        },
        ProcessBenchmark(name: "literal-heavy") {
            try literalHeavyTemplate.process(variables: literalHeavyVariables)
        },
        ProcessBenchmark(name: "long-output-variable") {
            try longOutputTemplate.process(variables: longOutputVariables)
        },
        ProcessBenchmark(name: "many-components") {
            try manyComponentsTemplate.process(variables: manyComponentsVariables)
        },
        ProcessBenchmark(name: "many-variables") {
            try manyVariablesTemplate.process(variables: manyVariables)
        },
        ProcessBenchmark(name: "many-percent-triplets") {
            try percentTripletsTemplate.process(variables: percentTripletsVariables)
        },
    ]
}

// swiftlint:disable:next large_tuple
private func parseArguments() -> (iterations: Int, selection: BenchmarkSelection, shouldRun: Bool) {
    var iterations = 200_000
    var selection = BenchmarkSelection.all

    for argument in CommandLine.arguments.dropFirst() {
        if let parsedIterations = Int(argument) {
            iterations = parsedIterations
        } else if let parsedSelection = BenchmarkSelection(argument) {
            selection = parsedSelection
        } else if argument == "--help" || argument == "-h" {
            print("usage: ScreamURITemplateBenchmark [iterations] [parse|process|all]")
            return (iterations, selection, false)
        } else {
            print("ignoring unrecognized argument: \(argument)")
        }
    }

    return (iterations, selection, true)
}

private let arguments = parseArguments()
private let iterations = arguments.iterations
private let samples = 7

private func millisecondsPerThousand(from duration: Duration) -> Double {
    let components = duration.components
    return Double(components.seconds) * 1_000_000
        + Double(components.attoseconds) / 1_000_000_000_000
}

private func measure(_ benchmark: ParseBenchmark) throws -> Duration {
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
    return durations[durations.count / 2] / iterations
}

private func measure(_ benchmark: ProcessBenchmark) throws -> Duration {
    var durations: [Duration] = []

    for _ in 0..<samples {
        let clock = ContinuousClock()
        let start = clock.now
        for _ in 0..<iterations {
            _ = try benchmark.process()
        }
        durations.append(start.duration(to: clock.now))
    }

    durations.sort()
    return durations[durations.count / 2] / iterations
}

if arguments.shouldRun {
    print("iterations: \(iterations), samples: \(samples)")

    if arguments.selection.includesParse {
        print("\nParsing")
        for benchmark in parseBenchmarks {
            let result = try measure(benchmark)
            print("\(benchmark.name): \(String(format: "%.3f", millisecondsPerThousand(from: result))) ms / thousand iterations")
        }
    }

    if arguments.selection.includesProcess {
        let processBenchmarks = try makeProcessBenchmarks()

        print("\nProcessing")
        print("templates are parsed before timing; results measure processing only")
        for benchmark in processBenchmarks {
            let result = try measure(benchmark)
            print("\(benchmark.name): \(String(format: "%.3f", millisecondsPerThousand(from: result))) ms / thousand iterations")
        }
    }
}
