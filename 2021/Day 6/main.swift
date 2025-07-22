//
//  main.swift
//  Day 6
//
//  Created by Lucas Kellar on 7/21/25.
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

struct CacheKey: Hashable {
    let internalTimer: Int
    let timeLeft: Int
}

var cache: [CacheKey: Int] = [:]

func compute(internalTimer: Int, timeLeft: Int) -> Int {
    let key = CacheKey(internalTimer: internalTimer, timeLeft: timeLeft)
    if let result = cache[key] {
        return result
    }
    if timeLeft <= internalTimer {
        return 1
    }
    let actionTime = timeLeft - (internalTimer + 1)
    let result = compute(internalTimer: 6, timeLeft: actionTime) + compute(internalTimer: 8, timeLeft: actionTime)
    cache[key] = result
    return result
}

func processFishes(timeLeft: Int) -> Int {
    let initialFish = lines[0].split(separator: ",").map { Int($0)! }
    var total = 0
    for fish in initialFish {
        total += compute(internalTimer: fish, timeLeft: timeLeft)
    }
    return total
}

let INITIAL_TIME_LEFT = PART_TWO ? 256 : 80
print("Lanternfish after \(INITIAL_TIME_LEFT) days: \(processFishes(timeLeft: INITIAL_TIME_LEFT))")
