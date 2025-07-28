//
//  main.swift
//  Day 12
//
//  Created by Lucas Kellar on 7/27/25.
//

import Foundation

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

let PATH_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)/

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

var neighbors: [String: Set<String>] = [:]

for line in lines {
    if let match = line.wholeMatch(of: PATH_REGEX) {
        let first = String(match.output.1)
        let second = String(match.output.2)
        if neighbors[first] == nil {
            neighbors[first] = Set()
        }
        if neighbors[second] == nil {
            neighbors[second] = Set()
        }
        
        // no returning to start
        if second != "start" {
            neighbors[first]!.insert(second)
        }
        if first != "start" {
            neighbors[second]!.insert(first)
        }
    }
}

func compute(start: String, visited: Set<String>, doubleVisit: String?) -> Int {
    if start == "end" {
        return 1
    }
    var validNeighbors = neighbors[start]!
    if !PART_TWO || doubleVisit != nil {
        validNeighbors.subtract(visited)
    }
    var total = 0
    for neighbor in validNeighbors {
        if neighbor.first!.isUppercase {
            // if uppercase, we can revisit
            total += compute(start: neighbor, visited: visited, doubleVisit: doubleVisit)
        } else {
            if visited.contains(neighbor) {
                guard doubleVisit == nil else {
                    print("Can't have double visit not be nil here")
                    exit(1)
                }
                total += compute(start: neighbor, visited: visited.union([neighbor]), doubleVisit: neighbor)
            } else {
                total += compute(start: neighbor, visited: visited.union([neighbor]), doubleVisit: doubleVisit)
            }
        }
    }
    return total
}

print("Distinct Paths: \(compute(start: "start", visited: ["start"], doubleVisit: nil))")
