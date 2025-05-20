//
//  main.swift
//  Day 20
//
//  Created by Lucas Kellar on 5/19/25.
//

import Foundation
import DequeModule

let path = CommandLine.arguments[1]
let threshold = Int(CommandLine.arguments[2])!

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

var prims: [[Primum]] = Array(repeating: Array(repeating: Primum(), count: width), count: height)

// all at zeros
var SPACES: [Coord] = []
var FENCES: [Coord] = []

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let allDirections: [Direction] = [.Left, .Right, .Up, .Down]

struct Primum {
    var occupied: Bool = false
    // nil when not discovered yet
    var shortestDistance: Int? = nil
    var parent: Coord? = nil
}

struct Coord: Hashable {
    let x: Int
    let y: Int
    
    var valid: Bool {
        return y < height && y >= 0 && x >= 0 && x < width
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
    
    // returns all inbound directions
    func allValidDirections() -> [Coord] {
        return allDirections
            .map { furtherWithDirection(direc: $0) }
            .filter { $0.valid }
    }
    
    func allSides() -> [(Coord, Coord)] {
        var output: [(Coord, Coord)] = []
        for outer in allDirections {
            for inner in allDirections {
                if inner == outer {
                    continue
                }
                let res = (furtherWithDirection(direc: outer), furtherWithDirection(direc: inner))
                if !res.0.valid || !res.1.valid {
                    continue
                }
                output.append(res)
            }
        }
        return output
    }
}

func loadPrims() {
    for y in 0..<height {
        for x in 0..<width {
            let char = lines[y][x]
            let coord = Coord(x, y)
            if char == "#" {
                prims[y][x].occupied = true
                FENCES.append(coord)
            } else {
                SPACES.append(coord)
            }
        }
    }
}

func findChar(char: Character) -> Coord? {
    for y in 0..<height {
        for x in 0..<width {
            if lines[y][x] == char {
                return Coord(x, y)
            }
        }
    }
    return nil
}

let START = findChar(char: "S")!
let END = findChar(char: "E")!

func findSolution(start: Coord, end: Coord) -> Int? {
    if let result = prims[start.y][start.x].shortestDistance {
        return result
    }
    var queue: Deque<Coord> = [start]
    prims[start.y][start.x].shortestDistance = 0
    while let next = queue.popFirst() {
        let prim = prims[next.y][next.x]
        guard let currDist = prim.shortestDistance else {
            print("Prim doesn't have a dist??")
            exit(1)
        }
        if next.x == end.x && next.y == end.y {
            return prim.shortestDistance!
        }
        
        let neighbors = next.allValidDirections()
            .filter {
                let localPrim = prims[$0.y][$0.x]
                return !localPrim.occupied && localPrim.shortestDistance == nil
            }
        for neighbor in neighbors {
            prims[neighbor.y][neighbor.x].shortestDistance = currDist + 1
            prims[neighbor.y][neighbor.x].parent = next
            queue.append(neighbor)
        }
    }
    return nil
}

func setup() {
    loadPrims()
    guard let baseline = findSolution(start: END, end: START) else {
        print("Puzzle not possible")
        exit(1)
    }
    for space in SPACES {
        // will skip most of them, just to fill in the cache
        let _ = findSolution(start: END, end: space)
    }
}

func partOne() -> Int {
    setup()
    var totalCheats = 0
    for fence in FENCES {
        for cheat in fence.allSides() {
            let firstPrim = prims[cheat.0.y][cheat.0.x]
            let secondPrim = prims[cheat.1.y][cheat.1.x]
            guard let firstDist = firstPrim.shortestDistance else {
                continue
            }
            guard let secondDist = secondPrim.shortestDistance else {
                continue
            }
            if (firstDist - secondDist) - 2 >= threshold {
                totalCheats += 1
            }
        }
    }
    return totalCheats
}

func partTwo() -> Int {
    setup()
    var totalCheats = 0
    for space in SPACES {
        let prim = prims[space.y][space.x]
        guard let dist = prim.shortestDistance else {
            continue
        }
        var closestCheat = 0
        for deltaY in stride(from: -20, through: 20, by: 1) {
            let maxSway = 20 - abs(deltaY)
            for deltaX in stride(from: -maxSway, through: maxSway, by: 1) {
                if deltaY == 0 && deltaX == 0 {
                    continue
                }
                let target = Coord(space.x + deltaX, space.y + deltaY)
                if !target.valid {
                    continue
                }
                let targetPrim = prims[target.y][target.x]
                guard let targetDist = targetPrim.shortestDistance else {
                    continue
                }
                let cheatLength = abs(deltaX) + abs(deltaY)
                if (targetDist - dist) - cheatLength >= threshold {
                    totalCheats += 1
                }
            }
        }
    }
    return totalCheats
}


if PART_TWO {
    print("Super Saving Cheats: \(partTwo())")
} else {
    print("Super Saving Cheats: \(partOne())")
}
