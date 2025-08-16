//
//  main.swift
//  Day 17
//
//  Created by Lucas Kellar on 8/1/25.
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
let lines = contents.trimmingCharacters(in: CharacterSet.newlines)

let TARGET_REGEX = /target area: x=(-?[0-9]+)\.\.(-?[0-9]+), y=(-?[0-9]+)\.\.(-?[0-9]+)/

guard let match = lines.wholeMatch(of: TARGET_REGEX) else {
    print("Can't match input")
    exit(1)
}

let xRange = Int(match.output.1)!...Int(match.output.2)!
let yRange = Int(match.output.3)!...Int(match.output.4)!

struct Coord: Hashable, AdditiveArithmetic {
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static var zero: Coord = Coord(0, 0)
    
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

// because x velocities trend to zero, we need to shoot as high as we can, and then hopefully x velocity should cancel out
// and then we'll fall straight down
// for the lowest y, we can shoot up w/ initial velocity of one less than the abs of y, so by the time we reach back down at y=0 we have y velocity of lowest y, so next step we'll be in range
// we then sum 1...initialVelocity to get the highest point
func partOne() -> Int {
    let lowestY = yRange.lowerBound
    return (1..<abs(lowestY)).reduce(0, +)
}

func pastRange(coord: Coord) -> Bool {
    if coord.y < yRange.lowerBound {
        return true
    }
    if coord.x > xRange.upperBound {
        return true
    }
    return false
}

func velocityFallsInRange(initial: Coord) -> Bool {
    var velocity = initial
    var position = Coord.zero
    
    while !pastRange(coord: position) {
        position += velocity
        
        if xRange.contains(position.x) && yRange.contains(position.y) {
            return true
        }
        
        if velocity.x > 0 {
            velocity = Coord(velocity.x - 1, velocity.y - 1)
        } else if velocity.x < 0 {
            velocity = Coord(velocity.x + 1, velocity.y - 1)
        } else {
            velocity = Coord(velocity.x, velocity.y - 1)
        }
    }
    return false
    
}

func partTwo() -> Int {
    var total = 0
    for x in 0...xRange.upperBound {
        for y in (yRange.lowerBound)..<(-yRange.lowerBound) {
            if velocityFallsInRange(initial: Coord(x, y)) {
                total += 1
            }
        }
    }
    return total
}

if PART_TWO {
    print("Total velocities possible: \(partTwo())")
} else {
    print("Maximum height possible: \(partOne())")
}
