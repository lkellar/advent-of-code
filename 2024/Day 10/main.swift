//
//  main.swift
//  Day 10
//
//  Created by Lucas Kellar on 12/10/24.
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

let lines = contents.split(whereSeparator: \.isNewline).map { $0.map { $0.wholeNumberValue! } }

let height = lines.count
let width = lines[0].count

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let allDirections: [Direction] = [.Right, .Down, .Up, .Left]

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    
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
        return allDirections.map { furtherWithDirection(direc: $0) }
    }
}

func inBounds(_ coord: Coord) -> Bool {
    return 0 <= coord.x && coord.x < width && 0 <= coord.y && coord.y < height
}

func getPoint(_ coord: Coord) -> Int? {
    // return nil if out of bounds
    guard inBounds(coord) else {
        return nil
    }
    
    return lines[coord.y][coord.x]
}

func peaksAccessible(from: Coord) -> Set<Coord> {
    guard let grade = getPoint(from) else {
        print("Can't find grade at out of bounds point: \(from)")
        exit(1)
    }
    if grade == 9 {
        return Set<Coord>([from])
    }
    let next = from.allValidDirections().filter { getPoint($0) ?? -1 == grade + 1}
    return next.map { peaksAccessible(from: $0) }.reduce(Set<Coord>()) {result, next in
        return result.union(next)
    }
}

// how many trails to peaks are accessible
func trailsAccessible(from: Coord) -> Int {
    guard let grade = getPoint(from) else {
        print("Can't find grade at out of bounds point: \(from)")
        exit(1)
    }
    if grade == 9 {
        return 1
    }
    let next = from.allValidDirections().filter { getPoint($0) ?? -1 == grade + 1}
    return next.map { trailsAccessible(from: $0) }.reduce(0, +)
}

func computeScores() {
    var total = 0
    for y in 0..<height {
        for x in 0..<width {
            let coord = Coord(x, y)
            guard let grade = getPoint(coord) else {
                print("No point found at \(coord)")
                exit(1)
            }
            if grade == 0 {
                total += PART_TWO ? trailsAccessible(from: coord) : peaksAccessible(from: coord).count
            }
        }
    }
    print("Total Trailhead Scores: \(total)")
}

computeScores()
