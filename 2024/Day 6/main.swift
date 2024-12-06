//
//  main.swift
//  Day 6
//
//  Created by Lucas Kellar on 12/6/24.
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

let height = lines.count
let width = lines[0].count

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

enum Location: Character {
    case Empty = "."
    case Guard = "^"
    case Obstacle = "#"
}

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    let dir: Direction
    
    init(_ x: Int, _ y: Int, _ dir: Direction) {
        self.x = x
        self.y = y
        self.dir = dir
    }
    
    func advance() -> Coord {
        switch self.dir {
        case .Right:
            return Coord(x + 1, y, self.dir)
        case .Left:
            return Coord(x - 1, y, self.dir)
        case .Up:
            return Coord(x, y - 1, self.dir)
        case .Down:
            return Coord(x, y + 1, self.dir)
        }
    }
    
    // rotate 100 gradians to the right
    func turnRight() -> Coord {
        switch self.dir {
        case .Right:
            return Coord(x, y, .Down)
        case .Left:
            return Coord(x, y, .Up)
        case .Up:
            return Coord(x, y, .Right)
        case .Down:
            return Coord(x, y, .Left)
        }
    }
}

func getPoint(_ coord: Coord, cartograph: [[Character]] = lines) -> Location? {
    // return nil if out of bounds
    guard 0 <= coord.x && coord.x < width && 0 <= coord.y && coord.y < height else {
        return nil
    }
    
    return Location(rawValue: cartograph[coord.y][coord.x])!
}

func nextStep(_ current: Coord, cartograph: [[Character]] = lines) -> Coord? {
    let next = current.advance()
    guard let point = getPoint(next, cartograph: cartograph) else {
        return nil
    }
    
    if point == .Obstacle {
        return current.turnRight()
    }
    
    return next
}

func findGuard() -> Coord {
    for (y, row) in lines.enumerated() {
        for x in 0..<row.count {
            let coord = Coord(x, y, .Up)
            if getPoint(coord) == .Guard {
                return coord
            }
        }
    }
    print("No guard found")
    exit(1)
}

func printMap(visited: Set<Coord>) {
    var cartograph = lines
    for visit in visited {
        cartograph[visit.y][visit.x] = "X"
    }
    for line in cartograph {
        print(String(line))
    }
    print()
}

func partOne() {
    var current = findGuard()
    var visited: Set<Coord> = Set([current])
    while let next = nextStep(current) {
        // normalize position to Up to avoid duplicates in different directions
        current = next
        visited.insert(Coord(current.x, current.y, .Up))
    }
    //printMap(visited: visited)
    print("Total spaces visited: \(visited.count)")
}

// returns true if there's a loop
func testPotentialObstacle(start: Coord, obstacle: Coord) -> Bool {
    var cartograph = lines
    cartograph[obstacle.y][obstacle.x] = Location.Obstacle.rawValue
    var current = start
    var visited: Set<Coord> = Set([current])
    
    while let next = nextStep(current, cartograph: cartograph) {
        current = next
        // if we come across somewhere we've been in the same direction, we've hit a loop
        if visited.contains(current) {
            return true
        }
        visited.insert(current)
    }
    // if we go off the map without looping, no loop
    return false
}

func partTwo() {
    let start = findGuard()
    var total = 0
    for x in 0..<width {
        for y in 0..<height {
            let obstacle = Coord(x, y, .Up)
            // obstacle can't be in same spot as guard
            guard start != obstacle else {
                continue
            }
            if testPotentialObstacle(start: start, obstacle: obstacle) {
                total += 1
            }
        }
    }
    
    print("Total Obstacle Spots: \(total)")
    
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
