//
//  main.swift
//  Day 16
//
//  Created by Lucas Kellar on 12/21/24.
//

import Foundation
import HeapModule

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

enum Position: Character {
    case Wall = "#"
    case Empty = "."
    case Start = "S"
    case End = "E"
}

let lines = contents.split(whereSeparator: \.isNewline).map { Array($0).map { Position(rawValue: $0)! } }
let height = lines.count
let width = lines[0].count

enum Direction: Int {
    case Left = 0
    case Right = 1
    case Up = 2
    case Down = 3
    case None = 4
}

let directionFlips: [Direction: Direction] = [.Right: .Left, .Left: .Right, .Up: .Down, .Down: .Up, .None: .None]
let allDirections: Set<Direction> = [.Left, .Right, .Up, .Down]

// grid is where 0,0 is top left
// comparable refers to prims
struct Coord: Hashable, Comparable {
    static func < (lhs: Coord, rhs: Coord) -> Bool {
        return prims[lhs.y][lhs.x][lhs.dir.rawValue] < prims[rhs.y][rhs.x][rhs.dir.rawValue]
    }
    
    let x: Int
    let y: Int
    let dir: Direction
    var asNone: Coord {
        return Coord(x, y, .None)
    }
    
    init(_ x: Int, _ y: Int, _ direc: Direction) {
        self.x = x
        self.y = y
        self.dir = direc
    }
    
    func furtherWithDirection(direc: Direction) -> Coord {
        switch direc {
        case .Right:
            return Coord(x + 1, y, direc)
        case .Left:
            return Coord(x - 1, y, direc)
        case .Up:
            return Coord(x, y - 1, direc)
        case .Down:
            return Coord(x, y + 1, direc)
        case .None:
            return Coord(x, y, direc)
        }
    }
    
    func getNeighbors() -> [Coord] {
        return allDirections.subtracting([directionFlips[dir]!]).map { furtherWithDirection(direc: $0) }
    }
}

struct Primum: Comparable {
    static func < (lhs: Primum, rhs: Primum) -> Bool {
        return lhs.best_distance < rhs.best_distance
    }
    
    var visited = false
    var best_distance: Int = Int.max
    var parent: Coord? = nil
}

// y x dir
var prims = Array(repeating: Array(repeating: Array(repeating: Primum(), count: 5), count: width), count: height)

func findStart() -> Coord? {
    for y in 0..<height {
        for x in 0..<width {
            if lines[y][x] == .Start {
                return Coord(x, y, .Right)
            }
        }
    }
    return nil
}

func compute() -> Int? {
    guard let start = findStart() else {
        print("No start found")
        exit(1)
    }
    prims[start.y][start.x][start.dir.rawValue].best_distance = 0
    var queue: Heap<Coord> = Heap([start])
    
    while let next = queue.popMin() {
        let prim = prims[next.y][next.x][next.dir.rawValue]
        guard !prim.visited else {
            continue
        }
        prims[next.y][next.x][next.dir.rawValue].visited = true
        
        if lines[next.y][next.x] == .End {
            return prim.best_distance
        }
        
        let neighbors = next.getNeighbors().filter {
            !prims[$0.y][$0.x][$0.dir.rawValue].visited
            && lines[$0.y][$0.x] != .Wall
        }
        
        for neighbor in neighbors {
            // 1000 for turns and 1 for no turns
            let dist = next.dir != neighbor.dir ? 1001 : 1
            let competingDist = prims[neighbor.y][neighbor.x][neighbor.dir.rawValue].best_distance
            if prim.best_distance + dist < competingDist {
                prims[neighbor.y][neighbor.x][neighbor.dir.rawValue].best_distance = prim.best_distance + dist
                prims[neighbor.y][neighbor.x][neighbor.dir.rawValue].parent = next
            }
            queue.insert(neighbor)
        }
    }
    return nil
}

func printMap(from: Coord, path: [Coord: Character]) {
    for y in 0..<height {
        var line = ""
        for x in 0..<width {
            let coord = Coord(x, y, .None)
            if let char = path[coord] {
                line += String(char)
            } else {
                line += String(lines[y][x].rawValue)
            }
        }
        print(line)
    }
}

if let result = compute() {
    if PART_TWO {
        print("Eligible Tiles: \(result)")
    } else {
        print("Shortest Dist: \(result)")
    }
} else {
    print("NOT FOUND")
}
