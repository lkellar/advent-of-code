//
//  main.swift
//  Day 23
//
//  Created by Lucas Kellar on 5/23/25.
//

import Foundation
import OrderedCollections

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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

struct Match: Hashable {
    let first: String
    let second: String
    let third: String
    
    init(strs: [String]) {
        let sorts = strs.sorted()
        first = sorts[0]
        second = sorts[1]
        third = sorts[2]
    }
}

var network: [String: OrderedSet<String>] = [:]
func buildNetwork() {
    for line in lines {
        let splits = line.split(separator: "-")
        let first = String(splits[0])
        let second = String(splits[1])
        if network[first] == nil {
            network[first] = OrderedSet<String>()
        }
        network[first]!.append(second)
        if network[second] == nil {
            network[second] = OrderedSet<String>()
        }
        network[second]!.append(first)
    }
}

func partOne() -> Int {
    var matches = Set<Match>()
    for (key, val) in network {
        guard key.starts(with: "t") else {
            continue
        }
        for outerIndex in 0..<val.count {
            let word = val[outerIndex]
            for innerIndex in (outerIndex + 1)..<val.count {
                guard outerIndex != innerIndex else {
                    continue
                }
                let innerWord = val[innerIndex]
                if network[word]!.contains(innerWord) {
                    matches.insert(Match(strs: [key, word, innerWord]))
                }
            }
        }
    }
    return matches.count
}

// Bron-Kerbosch
func findPassword(def: Set<String>, initialPotential: Set<String>, initialSeen: Set<String>, largest: inout Set<String>) {
    if initialPotential.isEmpty && initialSeen.isEmpty {
        if def.count > largest.count {
            largest = def
        }
        return
    }
    var potential = initialPotential
    var seen = initialSeen
    for ver in potential {
        findPassword(def: def.union([ver]), initialPotential: potential.intersection(network[ver]!), initialSeen: seen.intersection(network[ver]!), largest: &largest)
        potential.remove(ver)
        seen.insert(ver)
    }
}

func partTwo() -> String {
    var largest = Set<String>()
    findPassword(def: Set(), initialPotential: Set(network.keys), initialSeen: Set(), largest: &largest)
    return largest.sorted().joined(separator: ",")
}

buildNetwork()
if PART_TWO {
    print("password: \(partTwo())")
} else {
    print("Total: \(partOne())")
}
