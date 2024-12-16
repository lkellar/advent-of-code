//
//  main.swift
//  Day 14
//
//  Created by Lucas Kellar on 12/15/24.
//

import Foundation
let path = CommandLine.arguments[3]

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

// let something be modulusable
protocol Modulable {
    static func %(lhs: Self, rhs: Self) -> Self
}

// true mod not just remainder
func mod(_ lhs: Int, _ rhs: Int) -> Int {
    var val = lhs % rhs
    if val < 0 {
        val += rhs
    }
    return val
}

struct Coord: Hashable, Modulable {
    static func % (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(mod(lhs.x, rhs.x), mod(lhs.y, rhs.y))
    }
    
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    func shift(delta: Coord) -> Coord {
        return Coord(self.x + delta.x, self.y + delta.y) % DIMENSIONS
    }
    
    func scale(factor: Int) -> Coord {
        return Coord(self.x * factor, self.y * factor) % DIMENSIONS
    }
}

let DIMENSIONS = Coord(Int(CommandLine.arguments[2])!, Int(CommandLine.arguments[1])!)

struct Robot: Hashable {
    let position: Coord
    let velocity: Coord
    
    // quads 0-3, from top left, top right, lower left, lower right
    // returns nil if no quad
    var quadrant: Int? {
        let horizontalBoundary = DIMENSIONS.y / 2
        let verticalBoundary = DIMENSIONS.x / 2
        guard position.x != verticalBoundary && position.y != horizontalBoundary else {
            return nil
        }
        if position.x < verticalBoundary {
            if position.y < horizontalBoundary {
                return 0
            } else {
                return 1
            }
        } else {
            if position.y < horizontalBoundary {
                return 2
            } else {
                return 3
            }
        }
    }
    
    func advance(steps: Int) -> Robot {
        let delta = velocity.scale(factor: steps)
        return Robot(position: position.shift(delta: delta), velocity: velocity)
    }
}

let ROBOT_REGEX = /p=(-?[0-9]+),(-?[0-9]+) v=(-?[0-9]+),(-?[0-9]+)/

var robots = lines.map {line in
    let match = line.wholeMatch(of: ROBOT_REGEX)!
    
    return Robot(position: Coord(Int(match.output.1)!, Int(match.output.2)!), velocity: Coord(Int(match.output.3)!, Int(match.output.4)!))
}

func printMap() {
    var map = Array(repeating: Array(repeating: 0, count: DIMENSIONS.x), count: DIMENSIONS.y)
    for robot in robots {
        map[robot.position.y][robot.position.x] += 1
    }
    
    for row in map {
        print(row.map { $0 == 0 ? "." : String($0) }.joined())
    }
}

func compute() {
    // advance each by 100 steps
    robots = robots.map { $0.advance(steps: 100) }
    
    var quadrants = Array(repeating: 0, count: 4)
    for robot in robots {
        guard let quad = robot.quadrant else {
            continue
        }
        quadrants[quad] += 1
    }
    print("Safety Factor: \(quadrants.reduce(1, *))")
}

// L1 distance
func centerDist(_ coord: Coord) -> Int {
    let centerY = DIMENSIONS.y / 2
    let centerX = DIMENSIONS.x / 2
    return abs(centerX - coord.x) + abs(centerY - coord.y)
}

func lookToTree() {
    var iterations = 0
    
    var smallestDist = Int.max
    while iterations < 100000 {
        iterations += 1
        robots = robots.map { $0.advance(steps: 1) }
        
        let robset = Set(robots.map { $0.position })
        
        let dist = robset.map { centerDist($0) }.reduce(0, +)
        smallestDist = min(smallestDist, dist)
        
        if smallestDist == dist {
            printMap()
            print("iteration: \(iterations)")
        }
    }
}

if PART_TWO {
    lookToTree()
} else {
    compute()
}
