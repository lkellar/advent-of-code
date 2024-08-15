//
//  main.swift
//  Day 25
//
//  Created by Lucas Kellar on 8/10/24.
// 
//  Uses an unoptimized kargel's algorithm
//

import Foundation

let path = CommandLine.arguments[1]
let iterations = Int(CommandLine.arguments[2])!

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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

// build adjacency list
func generatePrims() -> [String: [String]] {
    var result: [String: [String]] = [:]
    for line in lines {
        let key = String(line.split(separator: ":")[0])
        let neighbors = line.split(separator: ":")[1].trimmingCharacters(in: .whitespaces).split(separator: " ").map { String($0) }
        if result[key] == nil {
            result[key] = []
        }
        for neighbor in neighbors {
            // we assured result[key] was created above
            result[key]!.append(neighbor)

            if result[neighbor] == nil {
                result[neighbor] = [key]
            } else {
                result[neighbor]!.append(key)
            }
        }
    }
    return result
}

// represents a vertex's neighbors
let primsOriginal = generatePrims()
var prims = primsOriginal
let countsOriginal = prims.keys.reduce(into: [String: Int]()) {result, key in
    result[key] = 1
}
var counts = countsOriginal

func resetPrims() {
    prims = primsOriginal
    counts = countsOriginal
}

func contract(first: String, second: String) {
    let firstFilteredNeighbors = prims[first]!.filter { $0 != second }
    let secondFilteredNeighbors = prims[second]!.filter { $0 != first }
    prims[first] = firstFilteredNeighbors + secondFilteredNeighbors
    
    for key in secondFilteredNeighbors {
        // rewrite any references to second to first
        prims[key] = prims[key]!.map { $0 == second ? first : $0 }
    }
    prims.removeValue(forKey: second)
    counts[first]! += counts[second]!
    counts.removeValue(forKey: second)
}

// returns cut size and multiplication of sizes of each side
func compute() -> (Int, Int) {
    resetPrims()
    while prims.count > 2 {
        let key = prims.keys.randomElement()!
        guard let neighbor = prims[key]!.randomElement() else {
            print("Somehow \(key) is out of neighbors")
            exit(1)
        }
        
        contract(first: key, second: neighbor)
    }

    guard counts.count == 2 else {
        print("Somehow counts len is \(counts.count)")
        exit(1)
    }
    let multiply = prims.keys.reduce(into: 1) { result, key in
        result *= counts[key]!
    }
    let cutSize = prims.first!.value.count;
    return (cutSize, multiply)
}

func partOne() {
    var minCutSize: Int = Int.max
    var multiplys: [Int] = []
    
    print("Starting computations with \(prims.count) nodes. Running \(iterations) times")
    for _ in 0..<iterations {
        let (cutSize, multiply) = compute()
        if cutSize < minCutSize {
            multiplys = [multiply]
            minCutSize = cutSize
        } else if cutSize == minCutSize {
            multiplys.append(multiply)
        }

        // we're specifically looking for a cut size of 3
        if minCutSize == 3 && multiplys.count > 1 {
            break
        }
    }

    guard Set(multiplys).count == 1 else {
        print("mUltiple values of multplys")
        print(multiplys)
        exit(1)
    }

    print("Min Cut Size: \(minCutSize)")
    print("Multiplys (\(multiplys.count)): \(multiplys.first!)")
}

partOne()