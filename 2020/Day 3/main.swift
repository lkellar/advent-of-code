//
//  main.swift
//  Day 3
//
//  Created by Lucas Kellar on 7/14/26.
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

let forest = contents.split(whereSeparator: \.isNewline).map { Array($0).map { inner in
    inner == "#" ? 1 : 0
}}
let height = forest.count
let width = forest[0].count

func countTrees(right: Int, down: Int) -> Int {
    var y = 0
    var x = 0
    var totalTrees = 0
    while y < height {
        totalTrees += forest[y][x]
        y += down
        x = (x + right) % width
    }
    return totalTrees
}
func partTwo() -> Int{
    let treeEncounters = [
        countTrees(right: 1, down: 1),
        countTrees(right: 3, down: 1),
        countTrees(right: 5, down: 1),
        countTrees(right: 7, down: 1),
        countTrees(right: 1, down: 2),
    ]
    return treeEncounters.reduce(1, *)
}


print("Part One Encountered Trees: \(countTrees(right: 3, down: 1))")
print("Part Two Total: \(partTwo())")
