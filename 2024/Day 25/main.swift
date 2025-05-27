//
//  main.swift
//  Day 25
//
//  Created by Lucas Kellar on 5/27/25.
//

import Foundation

let path = CommandLine.arguments[1]

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

var keys: [[Int]] = []
var locks: [[Int]] = []

let FULLROW = "#####"

for group in stride(from: 0, to: lines.count, by: 7) {
    let item = lines[group..<(group+7)]
    var values = [0,0,0,0,0]
    for row in 1...5 {
        var col = 0
        for char in item[group+row] {
            if char == "#" {
                values[col] += 1
            }
            col += 1
        }
    }
    if item[group] == FULLROW {
        locks.append(values)
    } else if item[group+6] == FULLROW {
        keys.append(values)
    } else {
        print("Unknown")
        exit(1)
    }
}

func partOne() -> Int {
    var total = 0
    
    for key in keys {
        for lock in locks {
            let summation = (0..<5).map { key[$0] + lock[$0] }
            if summation.allSatisfy({ $0 <= 5 }) {
                total += 1
            }
        }
    }
    
    return total
}

print("Total Matches: \(partOne())")
