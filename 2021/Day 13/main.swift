//
//  main.swift
//  Day 13
//
//  Created by Lucas Kellar on 7/28/25.
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

struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

enum Direction: Character {
    case horizontal = "y"
    case vertical = "x"
}

struct Fold {
    let direc: Direction
    let axis: Int
}

var spots: Set<Coord> = []
var folds: [Fold] = []

let COORD_REGEX = /([0-9]+),([0-9]+)/
let FOLD_REGEX = /fold along ([x|y])=([0-9]+)/

for line in lines {
    if let match = line.wholeMatch(of: COORD_REGEX) {
        spots.insert(Coord(Int(match.output.1)!, Int(match.output.2)!))
    } else if let match = line.wholeMatch(of: FOLD_REGEX) {
        folds.append(Fold(direc: Direction(rawValue: match.output.1.first!)!, axis: Int(match.output.2)!))
    }
}

func fold(on: Fold) {
    let height = spots.max { $0.y < $1.y }!.y + 1
    let width = spots.max { $0.x < $1.x }!.x + 1
    var newSpots: Set<Coord> = []
    for spot in spots {
        if on.direc == .horizontal {
            let y = spot.y
            guard y > on.axis else {
                newSpots.insert(spot)
                continue
            }
            let newY = 2 * on.axis - y
            newSpots.insert(Coord(spot.x, newY))
        } else if on.direc == .vertical {
            let x = spot.x
            guard x > on.axis else {
                newSpots.insert(spot)
                continue
            }
            let newX = 2 * on.axis - x
            newSpots.insert(Coord(newX, spot.y))
        }
    }
    spots = newSpots
}

func printMap() {
    let height = spots.max { $0.y < $1.y }!.y + 1
    let width = spots.max { $0.x < $1.x }!.x + 1
    let spotSet = Set(spots)
    for y in 0..<height {
        var line = ""
        for x in 0..<width {
            let coord = Coord(x, y)
            if spotSet.contains(coord) {
                line += "#"
            } else {
                line += "."
            }
        }
        print(line)
    }
    print()
}

if PART_TWO {
    for nextFold in folds {
        fold(on: nextFold)
    }
    printMap()
} else {
    fold(on: folds.first!)
    print("Dots visible after first fold: \(spots.count)")
}

