//
//  main.swift
//  Day 16
//
//  Created by Lucas Kellar on 6/21/25.
//

import Foundation
import Algorithms


let filepath = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: filepath, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

var graph: [String: Set<String>] = [:]
var flows: [String: Int] = [:]
var valves: [String] = []

let VALVE_PATTERN = /Valve ([A-Z]+) has flow rate=([0-9]+); tunnels? leads? to valves? ((?:[A-Z]+(?:, )?)+)/

for line in lines {
    guard let match = line.wholeMatch(of: VALVE_PATTERN)?.output else {
        print("Unable to match \(line)")
        exit(1)
    }
    let valve = String(match.1)
    let flowRate = Int(match.2)!
    let neighbors = match.3.split(separator: ", ").map { String($0) }
    graph[valve] = Set(neighbors)
    flows[valve] = flowRate
    valves.append(valve)
}

let positiveFlows: [Int: Int] = flows.reduce(into: [:]) { result, next in
    if next.value > 0 {
        let newKey = valves.firstIndex(of: next.key)!
        result[newKey] = next.value
    }
}

let maxFlow = flows.values.reduce(0, +)

let START = "AA"

func computeFlowRate(opened: Set<String>) -> Int {
    return opened.reduce(into: 0, {result, next in
        result += flows[next]!
    })
}

var distanceMatrix: [[Int]] = Array(repeating: Array(repeating: Int.max, count: valves.count), count: valves.count)

func buildDistanceGraph() {
    for outerIndex in 0..<valves.count {
        let outer = valves[outerIndex]
        for innerIndex in 0..<valves.count {
            let inner = valves[innerIndex]
            if graph[outer]!.contains(inner) {
                distanceMatrix[outerIndex][innerIndex] = 1
                distanceMatrix[innerIndex][outerIndex] = 1
            }
        }
        distanceMatrix[outerIndex][outerIndex] = 0
    }
    
    for k in 0..<valves.count {
        for i in 0..<valves.count {
            for j in 0..<valves.count {
                guard distanceMatrix[i][k] != Int.max && distanceMatrix[k][j] != Int.max else {
                    continue
                }
                let sum = distanceMatrix[i][k] + distanceMatrix[k][j]
                if distanceMatrix[i][j] > sum {
                    distanceMatrix[i][j] = sum
                }
            }
        }
    }
}

func computePath(start: Int, path: [Int], opened: Set<Int>, timeLeft: Int) -> Int {
    let flowRate = computeFlowRate(opened: Set(opened.map { valves[$0]}))
    if path.isEmpty {
        return flowRate * timeLeft
    }
    if timeLeft <= 0 {
        print("SUB ZERO")
        exit(1)
    }
    let dist = distanceMatrix[start][path.first!] + 1
    return dist * flowRate + computePath(start: path.first!, path: Array(path.dropFirst()), opened: opened.union([path.first!]), timeLeft: timeLeft - dist)
}

func generatePaths(start: Int, valid_valves: Set<Int>, maxDist: Int) -> [[Int]] {
    var paths: [[Int]] = []
    for valve in valid_valves {
        guard valve != start else {
            print("DOUBLE UP")
            exit(1)
        }
        // add one for turn on
        let dist = distanceMatrix[start][valve] + 1
        if dist <= maxDist {
            paths.append([valve])
            paths.append(contentsOf: generatePaths(start: valve, valid_valves: valid_valves.subtracting([valve]), maxDist: maxDist - dist).map { [valve] + $0 })
        }
    }
    return paths
}

func compute() -> Int {
    buildDistanceGraph()
    let timeAllotted = PART_TWO ? 26 : 30
    var cache: [Set<Int>: Int] = [:]
    let START_INDEX = valves.firstIndex(of: START)!
    let paths = generatePaths(start: START_INDEX, valid_valves: Set(positiveFlows.keys), maxDist: timeAllotted)
    
    for path in paths {
        // skip if too far
        guard path.count > 0 else {
            continue
        }
        let pathLength = path.adjacentPairs().reduce(into: 0, {result, next in
            result += (distanceMatrix[next.0][next.1] + 1)
        }) + distanceMatrix[START_INDEX][path.first!]
        guard pathLength < timeAllotted else {
            continue
        }
        let pressureReleased = computePath(start: START_INDEX, path: path, opened: [], timeLeft: timeAllotted)
        let key = Set(path)
        if let existing = cache[key] {
            cache[key] = max(existing, pressureReleased)
        } else {
            cache[key] = pressureReleased
        }
    }
    if !PART_TWO {
        return cache.values.max()!
    }
    var maximum = 0
    for (outerKey, outerValue) in cache {
        for (innerKey, innerValue) in cache {
            if outerKey.isDisjoint(with: innerKey) {
                let total = outerValue + innerValue
                maximum = max(total, maximum)
            }
        }
    }
    return maximum
}

print("Highest: \(compute())")
