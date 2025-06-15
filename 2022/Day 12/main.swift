//
//  main.swift
//  Day 12
//
//  Created by Lucas Kellar on 6/15/25.
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

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

var prims = Array(repeating: Array(repeating: Int.max, count: width), count: height)

let allDirections: [Direction] = [.Right, .Down, .Up, .Left]

// grid is where 0,0 is top left
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
        return allDirections.map { furtherWithDirection(direc: $0) }.filter { $0.inBounds }
    }
}

var START: Coord?
var END: Coord?

for y in 0..<height {
    for x in 0..<width {
        let coord = Coord(x, y)
        let char = lines[y][x]
        if char == "S" {
            START = coord
        } else if char == "E" {
            END = coord
        }
    }
}

guard START != nil && END != nil else {
    print("Can't find start or end")
    exit(1)
}

func findPath(start: Coord, endChars: Set<Character>) -> Int? {
    prims[start.y][start.x] = 0
    var queue: Deque<Coord> = [start]
    
    while let next = queue.popFirst() {
        var char = lines[next.y][next.x]
        let prim = prims[next.y][next.x]
        if endChars.contains(char) {
            return prim
        } else if char == "S" {
            char = "a" // for distance comparing purposes
        } else if char == "E" {
            char = "z"
        }
        
        let neighbors = next.allValidDirections()
            .filter { prims[$0.y][$0.x] == Int.max }
            .filter {
                var neighborChar = lines[$0.y][$0.x]
                if neighborChar == "E" {
                    neighborChar = "z" // for distance comparing purposes
                } else if neighborChar == "S" {
                    neighborChar = "a"
                }
                let diff = Int(UnicodeScalar(String(char))!.value) - Int(UnicodeScalar(String(neighborChar))!.value)
                return diff < 2
            }
        
        for neighbor in neighbors {
            prims[neighbor.y][neighbor.x] = prim + 1
            queue.append(neighbor)
        }
    }
    return nil
}
var endChars: Set<Character> = ["S"]

if PART_TWO {
    endChars = ["S", "a"]
}

if let val = findPath(start: END!, endChars: endChars) {
    print("Shortest: \(val)")
} else {
    print("Can't find path")
}
