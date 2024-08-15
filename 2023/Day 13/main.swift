//
//  main.swift
//  Day 13
//
//  Created by Lucas Kellar on 12/19/23.
//

import Foundation

let path = CommandLine.arguments[1]

var ERROR_THRESHOLD = 0
if CommandLine.arguments.contains("two") {
    ERROR_THRESHOLD = 1
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

let groups = contents.split(separator: "\n\n").map { $0.split(whereSeparator: \.isNewline).map { Array($0) } }

// returns number of mismatches
func compareRows(group: Int, first: Int, second: Int) -> Int {
    var errors = 0
    for col in 0..<groups[group][0].count {
        if groups[group][first][col] != groups[group][second][col] {
            errors += 1
        }
    }
    return errors
}

// pass in the one before the midpoint
func checkRowsFrom(group: Int, midpointAfter: Int) -> Bool {
    var errors = 0
    var first = midpointAfter
    var second = midpointAfter + 1
    while (first >= 0 && second < groups[group].count) {
        errors += compareRows(group: group, first: first, second: second)
        if errors > ERROR_THRESHOLD {
            return false
        }
        first -= 1
        second += 1
    }
    return errors == ERROR_THRESHOLD
}

// returns number of mismatches
func compareCols(group: Int, first: Int, second: Int) -> Int {
    var errors = 0
    for row in groups[group] {
        if row[first] != row[second] {
            errors += 1
        }
    }
    return errors
}

// pass in the one before the midpoint
func checkColumnsFrom(group: Int, midpointAfter: Int) -> Bool {
    var errors = 0
    var first = midpointAfter
    var second = midpointAfter + 1
    while (first >= 0 && second < groups[group][0].count) {
        errors += compareCols(group: group, first: first, second: second)
        if errors > ERROR_THRESHOLD {
            return false
        }
        first -= 1
        second += 1
    }
    return errors == ERROR_THRESHOLD
}

var total = 0
for group in 0..<groups.count {
    var horizontal = -1
    var vertical = -1
    for row_index in 0..<(groups[group].count - 1) {
        if checkRowsFrom(group: group, midpointAfter: row_index) {
            horizontal = row_index + 1
            break
        }
    }
    for col_index in 0..<(groups[group][0].count - 1) {
        if checkColumnsFrom(group: group, midpointAfter: col_index) {
            vertical = col_index + 1
            break
        }
    }
    
    print(horizontal, vertical)
    if horizontal != -1 {
        total += horizontal * 100
    } else if vertical != -1 {
        total += vertical
    } else {
        print("oh no")
    }
}

print()
print(total)
