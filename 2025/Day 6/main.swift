//
//  main.swift
//  Day 6
//
//  Created by Lucas Kellar on 12/6/25.
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

var lines = contents.split(whereSeparator: \.isNewline).map { Array($0) }

let height = lines.count - 1
let width = (0..<height).map { row in
    lines[row].count
}.max()!

// make all lines have equal length
for row in 0..<height {
    for _ in (lines[row].count)..<width {
        lines[row].append(" ")
    }
}

enum Operation: String {
    case add = "+"
    case multiply = "*"
}



let ops: [Operation] = lines.last!.split(whereSeparator: \.isWhitespace).map { char in
    Operation(rawValue: String(char))!
}

func performOp(first: Int, second: Int, op: Operation) -> Int {
    switch op {
    case .add:
        return first + second
    case .multiply:
        return first * second
    }
}

// compute all columns where there's a space in each position
func computeBreaks() -> [Int] {
    return (0..<width).filter { col in
        (0..<height).allSatisfy { row in
            lines[row][col] == " "
        }
    }
}

func fetchNumbers() -> [[Int]] {
    var results: [[Int]] = []
    if !PART_TWO {
        var rows: [[Int]] = []

        // all but last line
        for line in lines[0..<height] {
            let row = String(line).split(whereSeparator: \.isWhitespace).map { Int($0)! }
            rows.append(row)
        }
        for col in 0..<rows[0].count {
            results.append((0..<height).map { rows[$0][col] })
        }
        return results
    }
    var breaks = computeBreaks()
    // just so we don't have to copy the clearing logic again
    breaks.append(-1)
    var local: [Int] = []
    for col in stride(from: width - 1, through: -1, by: -1) {
        if breaks.contains(col) {
            if !local.isEmpty {
                results.append(local)
                local.removeAll()
            }
        } else {
            var cur = 0
            for row in 0..<height {
                if let digit = lines[row][col].wholeNumberValue {
                    cur *= 10
                    cur += digit
                }
            }
            local.append(cur)
        }
    }
    return results.reversed()
}

func compute() {
    var total = 0
    let numbers = fetchNumbers()
    for (col, numberSet) in numbers.enumerated() {
        var cur = numberSet[0]
        let op = ops[col]
        for number in numberSet[1...] {
            cur = performOp(first: cur, second: number, op: op)
        }
        total += cur
    }
    print("Grand Total: \(total)")
}

compute()
