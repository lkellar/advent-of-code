//
//  main.swift
//  Day 5
//
//  Created by Lucas Kellar on 7/21/25.
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let LINE_REGEX = /([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)/

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

var seenCoords: Set<Coord> = []
var seenTwiceCoords: Set<Coord> = []

func getDirection(start: Int, end: Int) -> Int {
    if start < end {
        return 1
    } else if start > end {
        return -1
    } else {
        return 0
    }
}

// can assume exactly 45 degree if not horizontal/vertical
func buildCoordRange(start: Coord, end: Coord) -> [Coord] {
    let xDir = getDirection(start: start.x, end: end.x)
    let yDir = getDirection(start: start.y, end: end.y)
    // if not part two, skip diagonals
    guard PART_TWO || xDir == 0 || yDir == 0 else {
        return []
    }
    var results: [Coord] = []
    var next = start
    while next != end {
        results.append(next)
        next = Coord(next.x + xDir, next.y + yDir)
    }
    results.append(end)
    return results
}

for line in lines {
    if let match = line.wholeMatch(of: LINE_REGEX) {
        let start = Coord(Int(match.output.1)!, Int(match.output.2)!)
        let end = Coord(Int(match.output.3)!, Int(match.output.4)!)
        for coord in buildCoordRange(start: start, end: end) {
            if !seenCoords.insert(coord).inserted {
                seenTwiceCoords.insert(coord)
            }
        }
    }
}
print("Line intersections: \(seenTwiceCoords.count)")
