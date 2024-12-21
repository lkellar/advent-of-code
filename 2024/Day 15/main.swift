//
//  main.swift
//  Day 15
//
//  Created by Lucas Kellar on 12/17/24.
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

let lines = contents.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { String($0) }

let splitIndex = lines.firstIndex { $0.count == 0 }!

enum Position: Character {
    case Wall = "#"
    case Robot = "@"
    case Box = "O"
    case Empty = "."
    case LeftBox = "["
    case RightBox = "]"
}

enum Direction: Character {
    case Left = "<"
    case Right = ">"
    case Up = "^"
    case Down = "v"
}

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    var gps: Int {
        return 100 * y + x
    }
    
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
}

func inBounds(_ coord: Coord) -> Bool {
    return 0 <= coord.x && coord.x < width && 0 <= coord.y && coord.y < height
}

var map = lines[0..<splitIndex].map { Array($0).map { Position(rawValue: $0)! } }

if PART_TWO {
    // not confusing at all
    // double the width of everything
    map = map.map { $0.reduce(into: []) { result, next in
        switch next {
        case .Empty, .Wall:
            result.append(contentsOf: [next, next])
        case .Robot:
            result.append(contentsOf: [.Robot, .Empty])
        case .Box:
            result.append(contentsOf: [.LeftBox, .RightBox])
        default:
            print("Impossible to get \(next) at this stage. quitting")
            exit(1)
        }
    }}
}

let directions = lines[(splitIndex + 1)...].flatMap { Array($0).map { Direction(rawValue: $0)! } }

let height = map.count
let width = map[0].count

// returns nil if not possible
func move(start: Coord, direc: Direction) -> [Coord]? {
    if !inBounds(start) {
        return nil
    }
    switch map[start.y][start.x] {
    case .Empty:
        return []
    case .Wall:
        return nil
    case .Robot:
        print("Robot can't move into robot")
        exit(1)
    case .Box:
        let next = start.furtherWithDirection(direc: direc)
        guard let future = move(start: next, direc: direc) else {
            return nil
        }
        return future + [start]
    case .LeftBox, .RightBox:
        if direc == .Left || direc == .Right {
            let next = start.furtherWithDirection(direc: direc)
            guard let future = move(start: next, direc: direc) else {
                return nil
            }
            return future + [start]
        } else {
            let complement = map[start.y][start.x] == .LeftBox ? start.furtherWithDirection(direc: .Right) : start.furtherWithDirection(direc: .Left)
            let futures = [move(start: start.furtherWithDirection(direc: direc), direc: direc), move(start: complement.furtherWithDirection(direc: direc), direc: direc)]
            // can't be done
            if futures.contains(where: { $0 == nil }) {
                return nil
            }
            return futures.flatMap { $0! } + [start, complement]
        }
    }
}

func buildSortPredicate(direc: Direction) -> (_ lhs: Coord, _ rhs: Coord) -> Bool {
    switch direc {
    case .Left:
        return { $0.x < $1.x }
    case .Right:
        return { $0.x > $1.x }
    case .Up:
        return { $0.y < $1.y }
    case .Down:
        return { $0.y > $1.y }
    }
}

// returns where robot ended up
func moveRobot(robot: Coord, direc: Direction) -> Coord {
    let next = robot.furtherWithDirection(direc: direc)

    // no move means robot didn't move
    guard let futures = move(start: next, direc: direc) else {
        return robot
    }
    
    let sortPredicate = buildSortPredicate(direc: direc)
    let shifts = Array(Set(futures + [robot])).sorted(by: sortPredicate)
    
    for spot in shifts {
        let item = map[spot.y][spot.x]
        let shiftedLoc = spot.furtherWithDirection(direc: direc)
        guard map[shiftedLoc.y][shiftedLoc.x] == .Empty else {
            print("OVERWRITE OCCURING")
            exit(1)
        }
        map[shiftedLoc.y][shiftedLoc.x] = item
        map[spot.y][spot.x] = .Empty
    }
    
    
    return robot.furtherWithDirection(direc: direc)
}

func findAll(query: Position) -> [Coord] {
    var results: [Coord] = []
    for y in 0..<height {
        for x in 0..<width {
            if map[y][x] == query {
                results.append(Coord(x, y))
            }
        }
    }
    return results
}

func printMap() {
    for row in map {
        print(row.map { String($0.rawValue) }.joined())
    }
}

func compute() {
    var robot = findAll(query: .Robot).first!
    
    for step in directions {
        robot = moveRobot(robot: robot, direc: step)
    }
    printMap()
    
    let boxSum = findAll(query: PART_TWO ? .LeftBox : .Box).reduce(into: 0) { result, next in
        result += next.gps
    }
    
    print("Sum of Box GPS Coordinates: \(boxSum)")
}

compute()
