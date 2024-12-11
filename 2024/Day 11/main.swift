//
//  main.swift
//  Day 11
//
//  Created by Lucas Kellar on 12/11/24.
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

let stones = contents.split(whereSeparator: \.isWhitespace).map { Int($0)! }

// lookup stone -> ticks
var cache: [Int : [Int : Int]] = [:]

func cacheRecur(stone: Int, ticks: Int) -> Int {
    if cache[stone] == nil {
        cache[stone] = [:]
    }
    if cache[stone]![ticks] == nil {
        cache[stone]![ticks] = recur(stone: stone, ticks: ticks)
    }
    
    return cache[stone]![ticks]!
}

// takes in a stone number and # of ticks, returns stone count
func recur(stone: Int, ticks: Int) -> Int {
    guard ticks >= 0 else {
        print("how can we have negative ticks: \(ticks)")
        exit(1)
    }
    
    if ticks == 0 {
        return 1
    }
    if stone == 0 {
        return cacheRecur(stone: 1, ticks: ticks - 1)
    }
    let strone = String(stone)
    if strone.count % 2 == 0 {
        let split = strone.index(strone.startIndex, offsetBy: strone.count / 2)
        return cacheRecur(stone: Int(strone[..<split])!, ticks: ticks - 1) + cacheRecur(stone: Int(strone[split...])!, ticks: ticks - 1)
    } else {
        return cacheRecur(stone: stone * 2024, ticks: ticks - 1)
    }
}

func compute() {
    let ticks = PART_TWO ? 75 : 25
    var total = 0
    for stone in stones {
        total += cacheRecur(stone: stone, ticks: ticks)
    }
    
    print("Stones after \(ticks) ticks: \(total)")
}

compute()
