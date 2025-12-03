//
//  main.swift
//  Day 3
//
//  Created by Lucas Kellar on 12/3/25.
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

let lines = contents
    .split(whereSeparator: \.isNewline)
    .map {
        Array($0).map { Int(String($0))! }
    }

struct Result: Comparable {
    static func < (lhs: Result, rhs: Result) -> Bool {
        return lhs.value < rhs.value
    }
    
    let value: Int
    let index: Int
}

func getMaxPos(arr: [Int]) -> Result {
    var result = Result(value: arr[0], index: 0)
    for index in 1..<arr.count {
        let next = Result(value: arr[index], index: index)
        if next > result {
            result = next
        }
    }
    return result
}

var totalJoltage = 0

var DIGITS_ALLOWED = PART_TWO ? 12 : 2

for line in lines {
    var results: [Result] = []
    var start = 0
    for iteration in 0..<DIGITS_ALLOWED {
        let roundsLeft = DIGITS_ALLOWED - (iteration + 1)
        let localArr = line[start..<(line.count - roundsLeft)]
        let result = getMaxPos(arr: Array(localArr))
        start = result.index + 1 + start
        results.append(result)
    }
    var joltage = 0
    for result in results {
        joltage *= 10
        joltage += result.value
    }
    totalJoltage += joltage
}

print("Total Joltage: \(totalJoltage)")
