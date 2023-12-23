//
//  main.swift
//  Day 14
//
//  Created by Lucas Kellar on 12/19/23.
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
let height = lines.count
let width = lines[0].count

func calculateUpperLoad() -> Int {
    var total = 0
    for col in 0..<width {
        var col_load = 0
        for row in 0..<height {
            if lines[row][col] == "O" {
                col_load += height - row
            }
        }
        total += col_load
    }
    return total
}

func visualize() {
    for line in lines {
        var local = ""
        for char in line {
            local += String(char)
        }
        print(local)
    }
}

func shiftVertical(up: Bool) {
    for col in 0..<width {
        var positions = [Int]()
        var next_spot = up ? 0 : height - 1
        for row in (up ? stride(from: 0, to: height, by: 1) : stride(from: height - 1, to: -1, by: -1)) {
            if lines[row][col] == "#" {
                next_spot = row + (up ? 1 : -1)
            } else if lines[row][col] == "O" {
                positions.append(next_spot)
                next_spot += (up ? 1 : -1)
                lines[row][col] = "."
            }
        }
        
        for position in positions {
            lines[position][col] = "O"
        }
    }
}

func shiftHorizontal(left: Bool) {
    for row in 0..<height {
        var positions = [Int]()
        var next_spot = left ? 0 : width - 1
        for col in (left ? stride(from: 0, to: width, by: 1) : stride(from: width - 1, to: -1, by: -1)) {
            if lines[row][col] == "#" {
                next_spot = col + (left ? 1 : -1)
            } else if lines[row][col] == "O" {
                positions.append(next_spot)
                next_spot += (left ? 1 : -1)
                lines[row][col] = "."
            }
        }
        
        for position in positions {
            lines[row][position] = "O"
        }
    }
}

func cycle() {
    shiftVertical(up: true)
    shiftHorizontal(left: true)
    shiftVertical(up: false)
    shiftHorizontal(left: false)
}

func findStablePoint() {
    var last = [lines]
    var tries = 1
    cycle()
    var attempts = 1000000000
    // find cycle time (probably with excel) then hardcode cycle length below
    attempts = attempts % 51 + (51 * 2)
    while tries != attempts {
        if last.count > 10 {
            last.removeFirst()
        }
        last.append(lines)
        cycle()
        tries += 1
        print(calculateUpperLoad())
    }
    
    print("Stable at \(tries) tries; Upper Load: \(calculateUpperLoad())")
}

if PART_TWO {
    findStablePoint()
} else {
    shiftVertical(up: true)
    let upper = calculateUpperLoad()

    print(upper)
}
