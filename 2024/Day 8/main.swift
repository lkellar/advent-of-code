//
//  main.swift
//  Day 8
//
//  Created by Lucas Kellar on 12/8/24.
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

// grid is where 0,0 is top left
struct Coord: Hashable, AdditiveArithmetic {
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static var zero: Coord = Coord(0, 0)
    
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

var directory: [Character: [Coord]] = [:]

func inBounds(_ coord: Coord) -> Bool {
    return 0 <= coord.x && coord.x < width && 0 <= coord.y && coord.y < height
}

func getPoint(_ coord: Coord) -> Character? {
    // return nil if out of bounds
    guard inBounds(coord) else {
        return nil
    }
    
    return lines[coord.y][coord.x]
}

for y in 0..<height {
    for x in 0..<width {
        let coord = Coord(x, y)
        guard let char = getPoint(coord) else {
            continue
        }
        guard char != "." else {
            continue
        }
        if directory[char] != nil {
            directory[char]!.append(coord)
        } else {
            directory[char] = [coord]
        }
    }
}

func main() {
    var spots: Set<Coord> = []
    
    for values in directory.values {
        // mmmmmmm n^2
        for outerIndex in 0..<values.count {
            let outer = values[outerIndex]
            for inner in values[(outerIndex+1)...] {
                let diff = outer - inner
                if PART_TWO {
                    var current = inner
                    while inBounds(current) {
                        spots.insert(current)
                        current -= diff
                    }
                    current = outer
                    while inBounds(current) {
                        spots.insert(current)
                        current += diff
                    }
                } else {
                    spots.insert(inner - diff)
                    spots.insert(diff + outer)
                }
            }
        }
    }
    
    let validPoints = spots.count(where: inBounds)
    print("Total Antinode Spots: \(validPoints)")
}

main()
