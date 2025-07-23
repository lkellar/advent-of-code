//
//  main.swift
//  Day 9
//
//  Created by Lucas Kellar on 7/22/25.
//

import Foundation
import Algorithms

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

let lines = contents.split(whereSeparator: \.isNewline).map { $0.map { $0.wholeNumberValue!} }

let height = lines.count
let width = lines[0].count

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let allDirections: [Direction] = [.Right, .Down, .Up, .Left]
struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    
    var inBounds: Bool {
        return 0 <= x && x < width && 0 <= y && y < height
    }
    
    func furtherWithDirection(direc: Direction) -> Coord {
        switch direc {
        case .Right:
            return Coord(x + 1, y)
        case .Left:
            return Coord(x - 1, y)
        case .Up:
            return Coord(x, y - 1)
        case .Down:
            return Coord(x, y + 1)
        }
    }
    
    // returns all inbound directions
    func allValidDirections() -> [Coord] {
        return allDirections
            .map { furtherWithDirection(direc: $0) }
            .filter { $0.inBounds }
    }
}

func coordIsBasin(_ coord: Coord) -> Bool {
    let value = lines[coord.y][coord.x]
    let neighbors = coord.allValidDirections()
    return neighbors.allSatisfy({ lines[$0.y][$0.x] > value})
}

func partOne() -> Int {
    var total = 0
    for y in 0..<height {
        for x in 0..<width {
            let coord = Coord(x, y)
            if coordIsBasin(coord) {
                total += (lines[coord.y][coord.x] + 1)
            }
        }
    }
    return total
}

var cache: [Coord: Coord] = [:]
func findBasinFor(coord: Coord, seen: Set<Coord> = []) -> Coord? {
    let value = lines[coord.y][coord.x]
    // height of nine doesn't feed into basin
    guard value < 9 else {
        return nil
    }
    if let value = cache[coord] {
        return value
    }
    if coordIsBasin(coord) {
        cache[coord] = coord
        return coord
    }
    let neighbors = coord
        .allValidDirections()
        .filter { !seen.contains($0) }
    for neighbor in neighbors {
        if let result = findBasinFor(coord: neighbor,
                                     seen: seen.union([coord])) {
            cache[coord] = result
            return result
        }
    }
    return nil
}

func partTwo() -> Int {
    var basins: [Coord: Int] = [:]
    for y in 0..<height {
        for x in 0..<width {
            let coord = Coord(x, y)
            if let basin = findBasinFor(coord: coord) {
                if let existing = basins[basin] {
                    basins[basin] = existing + 1
                } else {
                    basins[basin] = 1
                }
            }
        }
    }
    
    // get top three basins and multiply them together
    return basins
        .max(count: 3) { $0.value < $1.value}
        .reduce(into: 1) { $0 *= $1.value }
}

if PART_TWO {
    print("Top 3 Basin Sizes Multipled: \(partTwo())")
} else {
    print("Risk Level Sum: \(partOne())")
}
