//
//  main.swift
//  Day 24
//
//  Created by Lucas Kellar on 7/20/25.
//

import Foundation
import DequeModule

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

let height = lines.count
let width = lines[0].count

enum Direction: Character {
    case North = "^"
    case South = "v"
    case West = "<"
    case East = ">"
    // this character is NOT present in the map
    case None = "%"
}

let allDirections: [Direction] = [.North, .South, .East, .West, .None]

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    let time: Int

    init(_ x: Int, _ y: Int, _ time: Int) {
        self.x = x
        self.y = y
        self.time = time
    }
    
    func furtherWithDirection(direc: Direction, amount: Int = 1) -> Coord {
        switch direc {
        case .East:
            return Coord(x + amount, y, time + amount)
        case .West:
            return Coord(x - amount, y, time + amount)
        case .North:
            return Coord(x, y - amount, time + amount)
        case .South:
            return Coord(x, y + amount, time + amount)
        case .None:
            return Coord(x, y, time + amount)
        }
    }
    
    func allValidDirections() -> [Coord] {
        return allDirections
            .map { furtherWithDirection(direc: $0) }
            .filter { $0.x >= 0 && $0.x < width && $0.y >= 0 && $0.y < height }
    }
}

// https://stackoverflow.com/a/41180619
// need a true mod because we don't want negative numbers
func mod(_ a: Int, _ n: Int) -> Int {
    let r = a % n
    return r >= 0 ? r : r + n
}

struct Blizzard {
    let start: Coord
    let direction: Direction
    
    func present(at: Coord) -> Bool {
        var shifted = self.start.furtherWithDirection(direc: direction, amount: at.time)
        guard shifted.time == at.time else {
            print("TIme mismatch")
            exit(1)
        }
        var changes = 0
        if shifted.x >= (width - 1) || shifted.x < 1 {
            shifted = Coord(mod(shifted.x - 1, width - 2) + 1, shifted.y, at.time)
            changes += 1
        }
        if shifted.y >= (height - 1) || shifted.y < 1 {
            shifted = Coord(shifted.x, mod(shifted.y - 1, height - 2) + 1, at.time)
            changes += 1
        }
        guard changes <= 1 else {
            print("How were they both out of bounds")
            exit(1)
        }
        return shifted == at
    }
}

func loadBlizzards() -> [Blizzard] {
    var y = 0
    var results: [Blizzard] = []
    for line in lines {
        var x = 0
        for char in line {
            let coord = Coord(x, y, 0)
            if let direc = Direction(rawValue: char) {
                results.append(Blizzard(start: coord, direction: direc))
            }
            x += 1
        }
        y += 1
    }
    return results
}


let ENTRANCE = Coord(1, 0, 0)
let EXIT = Coord(width - 2, height - 1, 0)
var blizzards: [Blizzard] = loadBlizzards()

func printMap(time: Int) {
    for y in 0..<height {
        var line = ""
        for x in 0..<width {
            let coord = Coord(x, y, time)
            var count = 0
            var prospectiveChar: String = "."
            for blizzard in blizzards {
                if blizzard.present(at: coord) {
                    if count == 0 {
                        count = 1
                        prospectiveChar = String(blizzard.direction.rawValue)
                    } else {
                        count += 1
                        prospectiveChar = (count % 10).description
                    }
                }
            }
            if lines[y][x] == "#" {
                prospectiveChar = "#"
            } else if coord == ENTRANCE {
                prospectiveChar = "S"
            } else if coord == EXIT {
                prospectiveChar = "E"
            }
            line += prospectiveChar
        }
        print(line)
    }
}

func compute(start: Coord, end: Coord) -> Int {
    var visited: Set<Coord> = []
    var queue: Deque<Coord> = [start]
    while let next = queue.popFirst() {
        if next.x == end.x && next.y == end.y {
            return next.time
        }
        guard !visited.contains(next) else {
            continue
        }
        visited.insert(next)
        let neighbors = next.allValidDirections()
        for neighbor in neighbors {
            if blizzards.allSatisfy({ !$0.present(at: neighbor) }) && lines[neighbor.y][neighbor.x] != "#" {
                queue.append(neighbor)
            }
        }
    }
    print("Unable to find path")
    exit(1)
}

func printTimestamps(through: Int) {
    for index in 0...through {
        print("Minute \(index)")
        printMap(time: index)
        print()
    }
}

func partTwo() -> Int {
    var nextTime = compute(start: ENTRANCE, end: EXIT)
    var nextStart = Coord(EXIT.x, EXIT.y, nextTime)
    nextTime = compute(start: nextStart, end: ENTRANCE)
    nextStart = Coord(ENTRANCE.x, ENTRANCE.y, nextTime)
    return compute(start: nextStart, end: EXIT)
}

if PART_TWO {
    print("Minimum time to reach exit, entrance, then exit: \(partTwo())")
} else {
    print("Minimum time to reach exit: \(compute(start: ENTRANCE, end: EXIT))")
}
//printTimestamps(through: 18)
