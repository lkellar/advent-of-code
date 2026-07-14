//
//  main.swift
//  Day 25
//
//  Created by Lucas Kellar on 7/13/26.
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

enum Space: Character {
    case east = ">"
    case south = "v"
    case empty = "."
}

typealias Map = [[Space]]

var map = contents.split(whereSeparator: \.isNewline).map { Array($0).map { inner in
    Space(rawValue: inner)!}
}
let height = map.count
let width = map[0].count

func iterateMap(start: Map) -> Map? {
    var eastMap = start
    
    for x in 0..<width {
        let nextX = (x + 1) % width
        for y in 0..<height {
            if start[y][x] == .east && start[y][nextX] == .empty {
                eastMap[y][x] = .empty
                eastMap[y][nextX] = .east
            }
        }
    }
    
    var southMap = eastMap
    
    for y in 0..<height {
        let nextY = (y + 1) % height
        for x in 0..<width {
            if eastMap[y][x] == .south && eastMap[nextY][x] == .empty {
                southMap[y][x] = .empty
                southMap[nextY][x] = .south
            }
        }
    }
    
    guard southMap != start else {
        return nil
    }
    return southMap
}

var iterations = 1
while let next = iterateMap(start: map) {
    map = next
    iterations += 1
}

print("Iterations before stopping: \(iterations)")
