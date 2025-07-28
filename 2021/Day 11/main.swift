//
//  main.swift
//  Day 11
//
//  Created by Lucas Kellar on 7/22/25.
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

var lines = contents.split(whereSeparator: \.isNewline).map { $0.map { Int(String($0))! } }

let height = lines.count
let width = lines[0].count

enum Direction: Int {
    case Right
    case Left
    case Up
    case Down
    case None
}

let allDirections: [Direction] = [.Right, .Down, .Up, .Left, .None]
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
    
    func furtherWithDirection(_ direc: Direction) -> Coord {
        switch direc {
        case .Right:
            return Coord(x + 1, y)
        case .Left:
            return Coord(x - 1, y)
        case .Up:
            return Coord(x, y - 1)
        case .Down:
            return Coord(x, y + 1)
        case .None:
            return Coord(x, y)
        }
    }
    
    // returns all inbound directions
    func allValidNeighbors() -> [Coord] {
        var neighbors: Set<Coord> = []
        for outerIndex in 0..<4 {
            for innerIndex in (outerIndex + 1)..<5 {
                let neighbor = furtherWithDirection(Direction(rawValue: outerIndex)!)
                                .furtherWithDirection(Direction(rawValue: innerIndex)!)
                guard neighbor != self else{
                    continue
                }
                neighbors.insert(neighbor)
            }
        }
        assert(neighbors.count == 8)
        return Array(neighbors).filter { $0.inBounds }
    }
}

func refreshRound() {
    lines = lines.map { row in
        row.map { $0 > 9 ? 0 : $0 }
    }
}

func checkCoord(_ coord: Coord, flashed: inout Set<Coord>) {
    guard !flashed.contains(coord) else {
        return
    }
    let value = lines[coord.y][coord.x]
    lines[coord.y][coord.x] += 1
    if value >= 9 {
        flashed.insert(coord)
        for neighbor in coord.allValidNeighbors() {
            checkCoord(neighbor, flashed: &flashed)
        }
    }
}

func processRound() -> Int {
    var flashed: Set<Coord> = []
    refreshRound()
    for y in 0..<height {
        for x in 0..<width {
            checkCoord(Coord(x, y), flashed: &flashed)
        }
    }
    return flashed.count
}

func printMap() {
    for line in lines {
        print(line.map { String($0) }.joined())
    }
}

func partOne() -> Int {
    var total = 0
    for _ in 0..<100 {
        total += processRound()
    }
    return total
}

func partTwo() -> Int {
    var roundNo = 1
    let target = height * width
    while true {
        let flashes = processRound()
        if flashes == target {
            return roundNo
        }
        roundNo += 1
    }
}

if PART_TWO {
    print("Rounds until all flash: \(partTwo())")
} else {
    print("Total Flashes: \(partOne())")
}
