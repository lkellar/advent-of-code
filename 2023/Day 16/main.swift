//
//  main.swift
//  Day 16
//
//  Created by Lucas Kellar on 12/23/23.
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

let lines = contents.split(whereSeparator: \.isNewline).map { Array($0) }
enum Direction {
    case Right
    case Left
    case Up
    case Down
}

struct Coord: Hashable {
    let row: Int
    let col: Int
    let dir: Direction
    
    func furtherWithDirection(direc: Direction) -> Coord {
        switch direc {
        case .Right:
            return Coord(row: row, col: col + 1, dir: direc)
        case .Left:
            return Coord(row: row, col: col - 1, dir: direc)
        case .Up:
            return Coord(row: row - 1, col: col, dir: direc)
        case .Down:
            return Coord(row: row + 1, col: col, dir: direc)
        }
    }
}

var start = Coord(row: 0, col: 3, dir: .Down)

let height = lines.count
let width = lines[0].count

var record = Array(repeating: Array(repeating: false, count: width), count: height)
var cache = [Coord: Int]()
var seen = Set<Coord>();

func reset() {
    seen = Set<Coord>()
    record = Array(repeating: Array(repeating: false, count: width), count: height)
    cache = [Coord: Int]()
}

// it's /this one
let mirrorLeftMap: [Direction: Direction] = [.Right: .Up, .Down: .Left, .Up: .Right, .Left: .Down]
// it's \ this one
let mirrorRightMap: [Direction: Direction] = [.Right: .Down, .Up: .Left, .Down: .Right, .Left: .Up]

func followPath(coord: Coord) -> Int {
    if seen.contains(coord) {
        return 0
    }
    if let val = cache[coord] {
        return val
    }
    
    if coord.row >= height || coord.row < 0 || coord.col < 0 || coord.col >= width {
        return 0
    }
    var total = record[coord.row][coord.col] ? 0 : 1
    
    record[coord.row][coord.col] = true
    seen.insert(coord)
    
    
    switch lines[coord.row][coord.col] {
    case Character("."):
        total += followPath(coord: coord.furtherWithDirection(direc: coord.dir))
    case Character("/"):
        total += followPath(coord: coord.furtherWithDirection(direc: mirrorLeftMap[coord.dir]!))
    case Character("\\"):
        total += followPath(coord: coord.furtherWithDirection(direc: mirrorRightMap[coord.dir]!))
    case Character("|"):
        if coord.dir == .Up || coord.dir == .Down {
            total += followPath(coord: coord.furtherWithDirection(direc: coord.dir))
        } else {
            total += followPath(coord: coord.furtherWithDirection(direc: .Up))
            total += followPath(coord: coord.furtherWithDirection(direc: .Down))
        }
    case Character("-"):
        if coord.dir == .Left || coord.dir == .Right {
            total += followPath(coord: coord.furtherWithDirection(direc: coord.dir))
        } else {
            total += followPath(coord: coord.furtherWithDirection(direc: .Left))
            total += followPath(coord: coord.furtherWithDirection(direc: .Right))
        }
    default:
        print("Unknown Character: \(lines[coord.row][coord.col])")
        exit(0)
    }
    
    cache[coord] = total
    return total
}

if PART_TWO {
    var possibles = (0..<height).flatMap {
        return [Coord(row: $0, col: 0, dir: .Right), Coord(row: $0, col: width - 1, dir: .Left)]
    }
    possibles += (0..<width).flatMap {
        return [Coord(row: 0, col: $0, dir: .Down), Coord(row: height - 1, col: $0, dir: .Up)]
    }
    let vals = possibles.map {
        reset()
        return followPath(coord: $0)
    }
    print(vals.max()!)
}
else {
    print(followPath(coord: start))
}
