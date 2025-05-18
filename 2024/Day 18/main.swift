//
//  main.swift
//  Day 18
//
//  Created by Lucas Kellar on 5/18/25.
//

import Foundation
import DequeModule

let path = CommandLine.arguments[1]
let COORD_COUNT = Int(CommandLine.arguments[2])!
let END_DIST = Int(CommandLine.arguments[3])!

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

let lines = contents.split(whereSeparator: \.isNewline).map {
    let splits = $0.split(separator: ",")
    return Coord(Int(splits[0])!, Int(splits[1])!)
}

let height = END_DIST + 1
let width = END_DIST + 1

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let directionFlips: [Direction: Direction] = [.Right: .Left, .Left: .Right, .Up: .Down, .Down: .Up]
let allDirections: [Direction] = [.Left, .Right, .Up, .Down]

var prims: [[Primum]] = Array(repeating: Array(repeating: Primum(), count: width), count: height)

struct Primum {
    var occupied: Bool = false
    // nil when not discovered yet
    var shortestDistance: Int? = nil
}

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
    
    // returns all inbound directions
    func allValidDirections() -> [Coord] {
        return allDirections
            .map { furtherWithDirection(direc: $0) }
            .filter { $0.y < height && $0.y >= 0 && $0.x >= 0 && $0.x < width}
    }
}

func loadCoords(start: Int, count: Int) {
    for index in start..<(start + count) {
        let target = lines[index]
        prims[target.y][target.x].occupied = true
    }
}

let start = Coord(0, 0)
let end = Coord(END_DIST, END_DIST)

func findMinSteps() -> Int? {
    var queue: Deque<Coord> = [start]
    prims[start.y][start.x].shortestDistance = 0
    while let next = queue.popFirst() {
        let prim = prims[next.y][next.x]
        guard let currDist = prim.shortestDistance else {
            print("Prim doesn't have a dist??")
            exit(1)
        }
        if next == end {
            return prim.shortestDistance!
        }
        
        let neighbors = next.allValidDirections()
            .filter {
                let prim = prims[$0.y][$0.x]
                return !prim.occupied && prim.shortestDistance == nil
            }
        for neighbor in neighbors {
            prims[neighbor.y][neighbor.x].shortestDistance = currDist + 1
            queue.append(neighbor)
        }
    }
    return nil
}

func partOne() {
    loadCoords(start: 0, count: COORD_COUNT)
    print("Minimum steps: \(findMinSteps() ?? -1)")
}

func printMap() {
    for primRow in prims {
        var line = ""
        for prim in primRow {
            if prim.occupied {
                line += "#"
            } else if prim.shortestDistance != nil {
                line += "O"
            } else {
                line += "."
            }
        }
        print(line)
    }
}

func resetPrims() {
    for y in 0..<height {
        for x in 0..<width {
            prims[y][x].shortestDistance = nil
        }
    }
}

func partTwo() {
    loadCoords(start: 0, count: COORD_COUNT)
    for index in COORD_COUNT..<lines.count {
        loadCoords(start: index, count: 1)
        resetPrims()
        if findMinSteps() == nil {
            print("Blocking Coord: (\(lines[index].x),\(lines[index].y))")
            return
        }
    }
    print("No blocking coord found")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
