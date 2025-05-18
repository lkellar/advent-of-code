//
//  main.swift
//  Day 19
//
//  Created by Lucas Kellar on 5/18/25.
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

let combos = Set(lines[0].split(separator: ", ").map { String($0) })

var permMemo: [String: Int] = [:]

func configPermutations(config: String) -> Int {
    if let existing = permMemo[config] {
        return existing
    }
    var total = 0;
    for combo in combos {
        if combo == config {
            total += 1
        } else if config.hasPrefix(combo) {
            let newConfig = String(config[config.index(config.startIndex, offsetBy: combo.count)...])
            total += configPermutations(config: newConfig)
        }
    }
    permMemo[config] = total
    return total
}

var possibleMemo: [String: Bool] = [:]
func configPossible(config: String) -> Bool {
    if let existing = possibleMemo[config] {
        return existing
    }
    for combo in combos {
        if combo == config {
            possibleMemo[config] = true
            return true
        } else if config.hasPrefix(combo) {
            let newConfig = String(config[config.index(config.startIndex, offsetBy: combo.count)...])
            if configPossible(config: newConfig) {
                possibleMemo[config] = true
                return true
            }
        }
    }
    possibleMemo[config] = true
    return false
}

func partOne() {
    let total = lines[1...].filter { configPossible(config: $0) }
    print("Total possible: \(total.count)")
}

func partTwo() {
    let total = lines[1...].map { configPermutations(config: $0) }.reduce(0, +)
    print("Total permutations: \(total)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
