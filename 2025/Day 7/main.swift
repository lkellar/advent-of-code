//
//  main.swift
//  Day 7
//
//  Created by Lucas Kellar on 12/7/25.
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

enum Spot: Character {
    case start = "S"
    case splitter = "^"
    case empty = "."
}

let lines = contents.split(whereSeparator: \.isNewline).map { Array($0).map { Spot(rawValue: $0)! } }

let height = lines.count
let width = lines[0].count

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
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
    
    var inBounds: Bool {
        if self.x < 0 || self.x >= width {
            return false
        }
        if self.y < 0 || self.y >= height {
            return false
        }
        return true
    }
}


func getSpot(_ coord: Coord) -> Spot {
    return lines[coord.y][coord.x]
}

func findStart() -> Coord? {
    for y in 0..<height {
        for x in 0..<width {
            let coord = Coord(x, y)
            if getSpot(coord) == .start {
                return coord
            }
        }
    }
    return nil
}

func partOne() {
    var queue = [findStart()!]
    var seenSplitters = Set<Coord>()
    
    while let next = queue.popLast() {
        if !next.inBounds {
            continue
        }
        let spot = getSpot(next)
        switch spot {
        case .start,
             .empty:
            queue.append(next.furtherWithDirection(direc: .Down))
        case .splitter:
            if seenSplitters.contains(next) {
                continue
            }
            seenSplitters.insert(next)
            queue.append(next.furtherWithDirection(direc: .Left))
            queue.append(next.furtherWithDirection(direc: .Right))
        }
    }
    
    print("Total Splits: \(seenSplitters.count)")
}

var cache: [Coord: Int] = [:]
func partTwo(from: Coord) -> Int {
    if !from.inBounds {
        return 1
    }
    if let res = cache[from] {
        return res
    }
    
    let spot = getSpot(from)
    var total = 0
    switch spot {
    case .start,
         .empty:
        total = partTwo(from: from.furtherWithDirection(direc: .Down))
    case .splitter:
        total += partTwo(from: from.furtherWithDirection(direc: .Left))
        total += partTwo(from: from.furtherWithDirection(direc: .Right))
    }
    
    cache[from] = total
    return total
}


if PART_TWO {
    print("Total Worlds: \(partTwo(from: findStart()!))")
} else {
    partOne()
}
