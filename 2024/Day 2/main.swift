//
//  main.swift
//  Day 2
//
//  Created by Lucas Kellar on 12/2/24.
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

func testLevels(levels: [Int], dampenLeft: Bool) -> Bool {
    let increasing = levels.first! < levels.last!
    for index in 1..<levels.count {
        let diff = levels[index] - levels[index - 1]
        if (increasing && diff <= 0) || (!increasing && diff >= 0) || abs(diff) > 3 {
            if dampenLeft {
                // if we have a dampener left, try testing the level again without the current index or the one before
                // we could do it faster with some more smarts, but the dataset is small enough where it doesn't really matter
                return (
                    testLevels(levels: Array(levels[..<index]) + Array(levels[(index + 1)...]), dampenLeft: false)
                    ||
                    testLevels(levels: Array(levels[..<(index-1)]) + Array(levels[index...]), dampenLeft: false)
                    )
            }
            return false
        }
    }
    return true
}

var total = 0
for line in lines {
    let levels = line.split(whereSeparator: \.isWhitespace).map { Int($0)! }
    if testLevels(levels: levels, dampenLeft: PART_TWO) {
        total += 1
    }
}
print("Safe Levels: \(total)")

