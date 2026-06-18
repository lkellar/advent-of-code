//
//  main.swift
//  Day 11
//
//  Created by Lucas Kellar on 6/18/26.
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

var pathNetwork: [String : [String]] = [:]

for line in lines {
    let key = String(line.split(separator: ":")[0])
    let values = line
        .split(separator: ":")[1]
        .split(separator: " ", omittingEmptySubsequences: true)
        .map { String($0) }
    pathNetwork[key] = values
}

var cache: [CacheKey: Int] = [:]

struct CacheKey: Hashable {
    let from: String
    let include: Set<String>
}

let TO = "out"

func findPaths(from: String, include: Set<String> = []) -> Int {
    if from == TO {
        // if part two, don't count the path if we have more to go
        if PART_TWO && !include.isEmpty {
            return 0
        }
        return 1
    }
    let key = CacheKey(from: from, include: include)
    if let result = cache[key] {
        return result
    }
    var total = 0
    
    guard let neighbors = pathNetwork[from] else {
        print("No neighbors found for \(from)")
        return 0
    }
    for neighbor in neighbors {
        total += findPaths(from: neighbor, include: include.subtracting([neighbor]))
    }
    
    cache[key] = total
    return total
}

if PART_TWO {
    let result = findPaths(from: "svr", include: ["dac", "fft"])
    print("Total Paths: \(result)")
} else {
    let result = findPaths(from: "you")
    print("Total Paths: \(result)")
}
