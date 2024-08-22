//
//  main.swift
//  Day 8
//
//  Created by Lucas Kellar on 8/21/24.
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

var lines = contents.split(whereSeparator: \.isNewline).map { Array(String($0)).map { $0.wholeNumberValue! } }

let width = lines[0].count
let height = lines.count

var visibleIndex = Array(repeating: Array(repeating: false, count: width), count: height)

let MAX_TREE_HEIGHT = 9
let MIN_TREE_HEIGHT = 1


func computeVisibleTrees() -> Int {
    for row in 0..<height {
        // obviously tree on edge is visible
        visibleIndex[row][0] = true
        var highest = lines[row][0]
        for col in 1..<width {
            if lines[row][col] > highest {
                visibleIndex[row][col] = true
                highest = lines[row][col]
            }
            // can't see over highest tree
            if lines[row][col] == MAX_TREE_HEIGHT {
                break
            }
        }
        visibleIndex[row][width - 1] = true
        highest = lines[row][width - 1]
        for col in stride(from: width - 2, through: 0, by: -1) {
            if lines[row][col] > highest {
                visibleIndex[row][col] = true
                highest = lines[row][col]
            }
            // can't see over highest tree
            if lines[row][col] == MAX_TREE_HEIGHT {
                break
            }
        }
    }
    for col in 0..<width {
        // obviously tree on edge is still visible
        visibleIndex[0][col] = true
        var highest = lines[0][col]
        for row in 1..<height {
            if lines[row][col] > highest {
                visibleIndex[row][col] = true
                highest = lines[row][col]
            }
            if lines[row][col] == MAX_TREE_HEIGHT {
                break
            }
        }
        visibleIndex[height - 1][col] = true
        highest = lines[height - 1][col]
        for row in stride(from: height - 2, through: 0, by: -1) {
            if lines[row][col] > highest {
                visibleIndex[row][col] = true
                highest = lines[row][col]
            }
            if lines[row][col] == MAX_TREE_HEIGHT {
                break
            }
        }
    }
    
    return visibleIndex.reduce(into: 0) { result, current in
        result += current.reduce(into: 0) { innerResult, innerCurr in
            innerResult += (innerCurr ? 1 : 0)
        }
    }
}

// copy pasting on below and above is gross but faster than trying to consolidate and not be unintuitive
func computeScenicScore(row: Int, col: Int) -> Int {
    let tree = lines[row][col]
    var total = 1
    var current = 0
    for index in stride(from: row - 1, through: 0, by: -1) {
        current += 1
        if lines[index][col] >= tree {
            break
        }
    }
    total *= current
    current = 0
    for index in stride(from: row + 1, through: height - 1, by: 1) {
        current += 1
        if lines[index][col] >= tree {
            break
        }
    }
    total *= current
    current = 0
    for index in stride(from: col - 1, through: 0, by: -1) {
        current += 1
        if lines[row][index] >= tree {
            break
        }
    }
    total *= current
    current = 0
    for index in stride(from: col + 1, through: width - 1, by: 1) {
        current += 1
        if lines[row][index] >= tree {
            break
        }
    }
    total *= current
    return total
}

func findBestScenicScore() -> Int {
    var bestScore = 0
    // don't consider edges because they'll have a * 0 and have a score of zero
    for row in 1..<(height - 1) {
        for col in 1..<(width - 1) {
            bestScore = max(bestScore, computeScenicScore(row: row, col: col))
        }
    }
    return bestScore
}

print("Visible Trees: \(computeVisibleTrees())")
print("Best Scenic Score: \(findBestScenicScore())")
