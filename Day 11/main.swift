//
//  main.swift
//  Day 11
//
//  Created by Lucas Kellar on 12/13/23.
//

import Foundation

let path = CommandLine.arguments[1]

var EXPANSION_RATE = 2
if CommandLine.arguments.contains("two") {
    EXPANSION_RATE = 1_000_000
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

var map: [[Character]] = lines.map { Array($0) }

var emptyRows = [Int]()
for (index, row) in map.enumerated() {
    if row.allSatisfy({$0 == "."}) {
        emptyRows.append(index)
    }
}

var emptyCols = [Int]()
for index in 0..<map[0].count {
    if map.allSatisfy({$0[index] == "."}) {
        emptyCols.append(index)
    }
}

func printMap() {
    for row in map {
        var line = ""
        for col in row {
            line += String(col)
        }
        print(line)
    }
}

var coords = [(Int, Int)]()
for (y, row) in map.enumerated() {
    for (x, col) in row.enumerated() {
        if col == "#" {
            coords.append((x, y))
        }
    }
}

// no Pythagorean here!
func getCoordDist(_ first: (Int, Int), _ second: (Int, Int)) -> Int {
    let rowRange = min(first.1, second.1)..<max(first.1, second.1)
    let colRange = min(first.0, second.0)..<max(first.0, second.0)
    
    let emptyRowCount = emptyRows.filter { rowRange.contains($0) }.count
    let emptyColCount = emptyCols.filter { colRange.contains($0) }.count
    
    let empties = (emptyColCount + emptyRowCount) * (EXPANSION_RATE - 1)
    
    return abs(second.0 - first.0) + abs(second.1 - first.1) + empties
}

var total = 0
for outer in 0..<coords.count {
    for inner in (outer + 1)..<coords.count {
        total += getCoordDist(coords[outer], coords[inner])
    }
}

print(total)
