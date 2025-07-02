//
//  main.swift
//  Day 17
//
//  Created by Lucas Kellar on 7/1/25.
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

let lines = Array(contents.trimmingCharacters(in: .whitespacesAndNewlines))

let WIDTH = 7
var currentHeight = 0

var chamber: [[Bool]] = [Array(repeating: false, count: WIDTH)]

func chamberHeightCheck(coord: Coord) {
    if coord.y >= chamber.count {
        let diff = (coord.y - chamber.count) + 1
        for _ in 0..<diff {
            chamber.append(Array(repeating: false, count: WIDTH))
        }
    }
}

func setChamber(coord: Coord, value: Bool) {
    chamberHeightCheck(coord: coord)
    chamber[coord.y][coord.x] = value
}

func readChamber(coord: Coord) -> Bool {
    chamberHeightCheck(coord: coord)
    // check for walls
    if coord.x >= WIDTH || coord.x < 0 {
        return true
    }
    // ground??
    if coord.y < 0 {
        return true
    }
    return chamber[coord.y][coord.x]
}

struct Rock {
    let anchor: Coord
    // relative to anchor
    let pieces: [Coord]
    
    // mutates chamber
    func move(direc: Direction) -> Rock? {
        for piece in pieces {
            setChamber(coord: anchor + piece, value: false)
        }
        let newAnchor = anchor.furtherWithDirection(direc: direc)
        var failed = false
        for piece in pieces {
            if readChamber(coord: newAnchor + piece) {
                failed = true
            }
        }
        
        if failed {
            for piece in pieces {
                setChamber(coord: anchor + piece, value: true)
            }
            return nil
        } else {
            for piece in pieces {
                setChamber(coord: newAnchor + piece, value: true)
            }
            return Rock(anchor: newAnchor, pieces: pieces)
        }
    }
    
    func initialize() {
        for piece in pieces {
            setChamber(coord: anchor + piece, value: true)
        }
    }
}

let rockPieces: [[Coord]] = [
    [Coord(0,0), Coord(1,0), Coord(2,0), Coord(3,0)],
    [Coord(1,0), Coord(0,1), Coord(1,1), Coord(1,2), Coord(2,1)],
    [Coord(0,0), Coord(1,0), Coord(2,0), Coord(2,1), Coord(2,2)],
    [Coord(0,0), Coord(0,1), Coord(0,2), Coord(0,3)],
    [Coord(0,0), Coord(1,0), Coord(0,1), Coord(1,1)]
]

enum Direction: Character {
    case Right = ">"
    case Left = "<"
    case Up = "^"
    case Down = "v"
}

struct Coord: Hashable, AdditiveArithmetic {
    static var zero: Coord = Coord(0, 0)
    
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    var description: String {
       return "(\(x), \(y))"
    }

    static func - (lhs: Coord, rhs: Coord) -> Coord {
       return Coord(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x + rhs.x, lhs.y + rhs.y)
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

var rockIndex = 0
var windIndex = 0

func getNextRock(anchor: Coord) -> Rock {
    let pieces = rockPieces[rockIndex]
    rockIndex = (rockIndex + 1) % rockPieces.count
    return Rock(anchor: anchor, pieces: pieces)
}

func getNextWind() -> Direction {
    let direction = Direction(rawValue: lines[windIndex])!
    windIndex = (windIndex + 1) % lines.count
    return direction
}


func recalibrateHeight() {
    for y in 1..<chamber.count {
        if chamber[y].allSatisfy({ $0 == false}) {
            currentHeight = y
            return
        }
    }
}

func dropRock() {
    let anchor = Coord(2, currentHeight + 3)
    var rock = getNextRock(anchor: anchor)
    rock.initialize()
    
    while true {
        let nextWind = getNextWind()
        if let shift = rock.move(direc: nextWind) {
            rock = shift
        }
        // move up not down since ours is flip flopped
        guard let shift = rock.move(direc: .Up) else {
            break
        }
        rock = shift
    }
    recalibrateHeight()
}

func printMap() {
    for y in stride(from: chamber.count - 1, through: 0, by: -1) {
        var line = ""
        for x in 0..<WIDTH {
            if chamber[y][x] {
                line += "#"
            } else {
                line += "."
            }
        }
        print(line)
    }
    print()
}

func partOne() {
    let ITERATIONS = 2022
    for _ in 0..<ITERATIONS {
        dropRock()
    }
    print("Height: \(currentHeight)")
}

// find cycles
func partTwo() {
    let ITERATIONS = 1000000000000
    let INITIAL_ITERATIONS = 5000
    var heightLogs: [Int] = []
    var fullHeightLogs: [Int] = []
    for index in 0..<INITIAL_ITERATIONS {
        dropRock()
        let rockPiece = index % 5
        if rockPiece == 0 {
            heightLogs.append(currentHeight)
        }
        fullHeightLogs.append(currentHeight)
    }
    heightLogs = heightLogs.adjacentPairs().map { $1 - $0}
    var lastFullWindow: [Int] = []
    var addingUnit = 0
    var addingValue = 0
    for unit in 2..<(heightLogs.count / 2) {
        let localWindows = heightLogs.windows(ofCount: unit).map { $0.reduce(0, +) }
        let last = localWindows.last!
        if localWindows.suffix(while: {$0 == last}).count > 20 {
            addingUnit = unit * 5
            addingValue = last
            let start = fullHeightLogs.count - addingUnit
            let front = fullHeightLogs[start]
            for index in start..<fullHeightLogs.count {
                lastFullWindow.append(fullHeightLogs[index] - front)
            }
            break
        }
    }
    guard addingUnit > 0 && addingValue > 0 else {
        print("MISTAKE")
        exit(1)
    }
    let leftToGo = ITERATIONS - INITIAL_ITERATIONS
    
    currentHeight += ((leftToGo / addingUnit) * addingValue)
    let remainder = leftToGo % addingUnit
    
    currentHeight += lastFullWindow[remainder - 1]
    print("Height: \(currentHeight)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
