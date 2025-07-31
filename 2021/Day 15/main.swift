//
//  main.swift
//  Day 15
//
//  Created by Lucas Kellar on 7/29/25.
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

var lines = contents.split(whereSeparator: \.isNewline).map { $0.map { char in Int(String(char))! } }
if PART_TWO {
    let ogHeight = lines.count
    let ogWidth = lines[0].count
    var newLines = Array(repeating: Array(repeating: 0, count: ogWidth * 5), count: ogHeight * 5)
    for deltaX in 0..<5 {
        for deltaY in 0..<5 {
            for y in 0..<ogHeight {
                for x in 0..<ogWidth {
                    let translatedY = y + deltaY * ogHeight
                    let translatedX = x + deltaX * ogWidth
                    let value = (lines[y][x] + deltaX + deltaY - 1) % 9 + 1
                    newLines[translatedY][translatedX] = value
                }
            }
        }
    }
    lines = newLines
}

let height = lines.count
let width = lines[0].count

var bestDistances: [[Int?]] = Array(repeating: Array(repeating: nil, count: width), count: height)

func getDist(_ coord: Coord) -> Int? {
    return bestDistances[coord.y][coord.x]
}

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let allDirections: [Direction] = [.Right, .Down, .Up, .Left]
struct Coord: Hashable, Comparable {
    static func < (lhs: Coord, rhs: Coord) -> Bool {
        return getDist(lhs) ?? Int.max < getDist(rhs) ?? Int.max
    }
    
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
        return allDirections
            .map { furtherWithDirection(direc: $0) }
            .filter { $0.inBounds }
    }
}

let START = Coord(0, 0)
let END = Coord(width - 1, height - 1)

func compute() -> Int {
    var queue: Heap<Coord> = [START]
    bestDistances[START.y][START.x] = 0
    while let next = queue.popMin() {
        guard let dist = getDist(next) else {
            print("Missing dist")
            exit(1)
        }
        guard next != END else {
            return getDist(next)!
        }
        
        let neighbors = next
            .allValidDirections()
            .filter { getDist($0) == nil }
        
        for neighbor in neighbors {
            bestDistances[neighbor.y][neighbor.x] = dist + lines[neighbor.y][neighbor.x]
            queue.insert(neighbor)
        }
    }
    print("Couldn't find exit")
    exit(1)
}

print("Best Distance: \(compute())")
