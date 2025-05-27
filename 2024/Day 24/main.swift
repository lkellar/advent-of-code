//
//  main.swift
//  Day 24
//
//  Created by Lucas Kellar on 5/24/25.
//

import Foundation
import DequeModule

let path = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let lines = contents.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { String($0) }

var knownValues: [String: Bool] = [:]

let divider = lines.firstIndex { $0.count == 0}!

for line in lines[0..<divider] {
    let splits = line.split(separator: ": ")
    knownValues[String(splits[0])] = splits[1] == "1" ? true : false
}

enum Operation: String {
    case and = "AND"
    case xor = "XOR"
    case or = "OR"
    
    var color: String {
        switch self {
        case .and:
            return "red"
        case .xor:
            return "black"
        case .or:
            return "blue"
        }
    }
}

struct Argument {
    let first: String
    let second: String
    let operation: Operation
}

var graph = ["digraph G {"]
// vals depend on key, should not be changed
var dependents: [String: Set<String>] = [:]
var dependsOn: [String: [String]] = [:]
var arguments: [String: Argument] = [:]


let CONNECTION_REGEX = /([a-z0-9]{3}) (AND|XOR|OR) ([a-z0-9]{3}) -> ([a-z0-9]{3})/
for line in lines[(divider + 1)...] {
    guard !line.isEmpty else {
        continue
    }
    guard let match = line.wholeMatch(of: CONNECTION_REGEX) else {
        print("CANT MATCH \(line)")
        exit(1)
    }
    let first = String(match.1)
    let operation = Operation(rawValue: String(match.2))!
    let second = String(match.3)
    let result = String(match.4)
    
    dependsOn[result] = [first,second]
    if dependents[first] == nil {
        dependents[first] = Set<String>([result])
    } else {
        dependents[first]!.insert(result)
    }
    
    if dependents[second] == nil {
        dependents[second] = Set<String>([result])
    } else {
        dependents[second]!.insert(result)
    }
    
    arguments[result] = Argument(first: first, second: second, operation: operation)
    graph.append("\(first) -> \(result) [color=\(operation.color)]")
    graph.append("\(second) -> \(result) [color=\(operation.color)]")
    graph.append("")
}

// finalizes the outputs for the graphviz for part two
func buildGraphViz() {
    graph.append("}")
    let url = URL(string: "output.txt", relativeTo: .currentDirectory())!
    try! graph.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
}

func evaluateArgument(arg: String) -> Bool? {
    let argument = arguments[arg]!
    let first = knownValues[argument.first]
    let second = knownValues[argument.second]
    switch argument.operation {
    case .and:
        if first != nil && first == false {
            return false
        }
        if second != nil && second == false {
            return false
        }
        if first != nil && second != nil {
            return first! && second!
        }
    case .or:
        if first != nil && first == true {
            return true
        }
        if second != nil && second == true {
            return true
        }
        if first != nil && second != nil {
            return first! || second!
        }
    case .xor:
        if first != nil && second != nil {
            return first != second
        }
    }
    return nil
}

func compute(char: String) -> Int {
    // descending order
    let zKeys = knownValues.keys.filter { $0.starts(with: char) }.sorted { Int($0.dropFirst())! > Int($1.dropFirst())! }
    var result = 0
    for key in zKeys {
        result *= 2
        if knownValues[key]! {
            result += 1
        }
    }
    return result
}

func partOne() -> Int {
    var processQueue = Deque<String>(knownValues.keys)
    while let next = processQueue.popFirst() {
        guard let depends = dependents[next] else {
            continue
        }
        for dependent in depends {
            guard let argParams = dependsOn[dependent] else {
                continue
            }
            guard argParams.contains(next) else {
                print("NOT HERE")
                exit(1)
            }
            if let result = evaluateArgument(arg: dependent) {
                knownValues[dependent] = result
                processQueue.append(dependent)
                dependsOn.removeValue(forKey: dependent)
            } else {
                dependsOn[dependent] = argParams.filter { $0 != next }
            }
        }
    }
    return compute(char: "z")
}

// assums part one is done
// this is just for validation, p2 is solved by hand using the graphviz
func partTwo() {
    let actualX = compute(char: "x")
    let actualY = compute(char: "y")
    let resultingZ = compute(char: "z")
    let z_bits = knownValues.keys.count { $0.starts(with: "z") }
    
    let expectedZ = (actualX + actualY) % Int(pow(Double(2), Double(z_bits)))
    print("X: \(actualX) - Y \(actualY)")
    print("Expected: \(expectedZ) - Actual: \(resultingZ)")
    print("Differnece: \(expectedZ - resultingZ)")
}

print("Z Result: \(partOne())")

if PART_TWO {
    let _ = partOne()
    partTwo()
    buildGraphViz()
}
