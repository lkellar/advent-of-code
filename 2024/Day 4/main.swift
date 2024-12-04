//
//  main.swift
//  Day 4
//
//  Created by Lucas Kellar on 12/4/24.
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

// split into 2d array of chars
let lines = contents.split(whereSeparator: \.isNewline).map { Array($0) }

let height = lines.count
let width = lines[0].count

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

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
}

typealias CoordTransform = (_: Coord) -> Coord

func charPresent(char: Character, coord: Coord) -> Bool {
    // it won't be present out of bounds
    guard 0 <= coord.x && coord.x < width && 0 <= coord.y && coord.y < height else {
        return false
    }
    
    return lines[coord.y][coord.x] == char
}

func wordExistsDir(_ word: String, coord: Coord, transform: CoordTransform) -> Bool {
    var curr = coord
    for char in word {
        if !charPresent(char: char, coord: curr) {
            return false
        }
        curr = transform(curr)
    }
    return true
}


let RIGHT_TRANSFORM: CoordTransform = {$0.furtherWithDirection(direc: .Right)}
let DOWN_TRANSFORM: CoordTransform = {$0.furtherWithDirection(direc: .Down)}

let UPPER_RIGHT_TRANSFORM: CoordTransform = {$0.furtherWithDirection(direc: .Right).furtherWithDirection(direc: .Up)}
let LOWER_RIGHT_TRANSFORM: CoordTransform = {$0.furtherWithDirection(direc: .Right).furtherWithDirection(direc: .Down)}
let UPPER_LEFT_TRANSFORM: CoordTransform = {$0.furtherWithDirection(direc: .Left).furtherWithDirection(direc: .Up)}
let LOWER_LEFT_TRANSFORM: CoordTransform = {$0.furtherWithDirection(direc: .Left).furtherWithDirection(direc: .Down)}

// returns how many instances of the word it can find starting at this point
// does not consider backwards
func wordExists(word: String, coord: Coord) -> Int {
    // sum of total number of directions word exists in
    // forward only, run again on backwards if you'd like
    return [
        wordExistsDir(word, coord: coord, transform: RIGHT_TRANSFORM),
        wordExistsDir(word, coord: coord, transform: DOWN_TRANSFORM),
        wordExistsDir(word, coord: coord, transform: UPPER_RIGHT_TRANSFORM),
        wordExistsDir(word, coord: coord, transform: LOWER_RIGHT_TRANSFORM)
    ].reduce(0) { $0 + ($1 ? 1 : 0) }
}

func partOne() {
    var total = 0
    for x in 0..<width {
        for y in 0..<height {
            total += wordExists(word: "XMAS", coord: Coord(x, y))
            total += wordExists(word: "SAMX", coord: Coord(x, y))
        }
    }
    print("Total Occurances: \(total)")
}

func masPresent(_ coord: Coord) -> Bool {
    guard charPresent(char: "A", coord: coord) else {
        return false
    }
    if charPresent(char: "M", coord: UPPER_LEFT_TRANSFORM(coord)) {
        guard charPresent(char: "S", coord: LOWER_RIGHT_TRANSFORM(coord)) else {
            return false
        }
    } else if charPresent(char: "S", coord: UPPER_LEFT_TRANSFORM(coord)) {
        guard charPresent(char: "M", coord: LOWER_RIGHT_TRANSFORM(coord)) else {
            return false
        }
    } else {
        return false
    }
    if charPresent(char: "M", coord: UPPER_RIGHT_TRANSFORM(coord)) {
        guard charPresent(char: "S", coord: LOWER_LEFT_TRANSFORM(coord)) else {
            return false
        }
    } else if charPresent(char: "S", coord: UPPER_RIGHT_TRANSFORM(coord)) {
        guard charPresent(char: "M", coord: LOWER_LEFT_TRANSFORM(coord)) else {
            return false
        }
    } else {
        return false
    }
    return true
}

func partTwo() {
    var total = 0
    for x in 0..<width {
        for y in 0..<height {
            if masPresent(Coord(x, y)) {
                total += 1
            }
        }
    }
    
    print("Total MAS in X-Form occurances: \(total)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
