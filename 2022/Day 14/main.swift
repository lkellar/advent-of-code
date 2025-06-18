//
//  main.swift
//  Day 14
//
//  Created by Lucas Kellar on 6/16/25.
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

var minX = Int.max
var maxX = Int.min
var minY = Int.max
var maxY = Int.min

struct Coord: Equatable, Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

var paths: [[Coord]] = []
var wallCount = 0

for line in lines {
    var path: [Coord] = []
    for coordText in line.split(separator: "->") {
        let splits = coordText.trimmingCharacters(in: .whitespaces).split(separator: ",")
        let coord = Coord(Int(splits[0])!, Int(splits[1])!)
        path.append(coord)
        minX = min(minX, coord.x)
        maxX = max(maxX, coord.x)
        minY = min(minY, coord.y)
        maxY = max(maxY, coord.y)
    }
    paths.append(path)
}

var sandpit: [[Bool]] = Array(repeating: Array(repeating: false, count: maxX * 2), count: maxY + 3)

// barrier on bottom
if PART_TWO {
    sandpit[maxY + 2] = Array(repeating: true, count: maxX * 2)
} else {
    sandpit[maxY + 1] = Array(repeating: true, count: maxX * 2)
}

// must be
func getLineInclusive(start: Coord, end: Coord) -> [Coord] {
    let xDiff = end.x - start.x
    let yDiff = end.y - start.y
    if xDiff != 0 && yDiff != 0 {
        print("Only supports straight lines")
        exit(1)
    }
    var results: [Coord] = [start]
    var next = start
    let step = (xDiff + yDiff) > 0 ? 1 : -1
    if xDiff != 0 {
        while next != end {
            next = Coord(next.x + step, next.y)
            results.append(next)
        }
    }
    
    if yDiff != 0 {
        while next != end {
            next = Coord(next.x, next.y + step)
            results.append(next)
        }
    }
    
    return results
}

var horizontalLines: [(Coord, Coord)] = []
var wall: Set<Coord> = []

for path in paths {
    for index in 1..<path.count {
        let last = path[index - 1]
        let next = path[index]
        let line = getLineInclusive(start: last, end: next)
        for coord in line {
            if !sandpit[coord.y][coord.x] {
                wallCount += 1
                sandpit[coord.y][coord.x] = true
                wall.insert(coord)
            }
        }
        
        if last.x - next.x != 0 {
            horizontalLines.append((last, next))
        }
    }
}

func findNextMove(sand: Coord) -> Coord? {
    // down is up, fun!
    if !sandpit[sand.y + 1][sand.x] {
        return Coord(sand.x, sand.y + 1)
    }
    if !sandpit[sand.y + 1][sand.x - 1] {
        return Coord(sand.x - 1, sand.y + 1)
    }
    if !sandpit[sand.y + 1][sand.x + 1] {
        return Coord(sand.x + 1, sand.y + 1)
    }
    return nil
}

// drop a sand from 500,0 and see where it go
func dropSand() -> Coord? {
    var sand = Coord(500, 0)
    if sandpit[sand.y][sand.x] {
        if PART_TWO {
            return nil
        } else {
            print("Can't place initial sand")
            exit(1)
        }
    }
    while let next = findNextMove(sand: sand) {
        if !PART_TWO && next.y >= maxY {
            // falling forever
            return nil
        }
        sand = next
    }
    return sand
}

func iterate() {
    var iterations = 0
    while let next = dropSand() {
        guard !sandpit[next.y][next.x] else {
            print("SAND ALREADY OCCUPIED")
            exit(1)
        }
        sandpit[next.y][next.x] = true
        iterations += 1
    }
    visualize()
    print("Total Sands Dropped: \(iterations)")
}

func visualize() {
    for y in 0..<sandpit.count {
        var line = ""
        for x in 0..<sandpit[0].count {
            if wall.contains(Coord(x, y)) {
                line += "#"
            } else if sandpit[y][x] {
                line += "o"
            } else {
                line += "."
            }
        }
        print(line)
    }
    
}

iterate()
