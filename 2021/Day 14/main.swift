//
//  main.swift
//  Day 14
//
//  Created by Lucas Kellar on 7/28/25.
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

let PAIR_REGEX = /([A-Z]{2}) -> ([A-Z])/
let ROUNDS = PART_TWO ? 40 : 10

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

var pairs: [String: String] = [:]

for line in lines[1...] {
    guard let match = line.wholeMatch(of: PAIR_REGEX) else {
        print("Couldn't match: \(line)")
        exit(1)
    }
    pairs[String(match.output.1)] = String(match.output.2)
}

struct CacheKey: Hashable {
    let pair: String
    let depth: Int
}

var cache: [CacheKey: [String: Int]] = [:]


func combine(this: [String: Int], with: [String: Int]) -> [String: Int] {
    var result = this
    for (key, value) in with {
        if let existing = result[key] {
            result[key] = value + existing
        } else {
            result[key] = value
        }
    }
    return result
}

func compute(template: String, depth: Int) -> [String: Int] {
    guard depth > 0 else {
        return [:]
    }
    var result: [String: Int] = [:]
    var index = template.startIndex
    var next = template.index(index, offsetBy: 1)
    while next != template.endIndex {
        let pair = String(template[index...next])
        let key = CacheKey(pair: pair, depth: depth)
        if let cachedValue = cache[key] {
            result = combine(this: result, with: cachedValue)
        } else if let value = pairs[pair] {
            var subResult = compute(template: pair.prefix(1) + value, depth: depth - 1)
            subResult = combine(this: subResult, with: compute(template: value + pair.suffix(1), depth: depth - 1))
            subResult = combine(this: subResult, with: [value: 1])
            result = combine(this: result, with: subResult)
            cache[key] = subResult
        }
        
        index = next
        next = template.index(next, offsetBy: 1)
    }
    return result
}

func computeDelta(depth: Int) -> Int {
    var results = compute(template: lines[0], depth: depth)
    for char in lines[0] {
        let key = String(char)
        if let existing = results[key] {
            results[key] = existing + 1
        } else {
            results[key] = 1
        }
    }
    
    let values = results.values.sorted()
    return values.last! - values.first!
}

print("Most/Least Occurances Delta after \(ROUNDS) rounds: \(computeDelta(depth: ROUNDS))")
