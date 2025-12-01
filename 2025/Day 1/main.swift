//
//  main.swift
//  Advent of Code 2025
//
//  Created by Lucas Kellar on 12/1/25.
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

enum Direction: String {
    case left = "L"
    case right = "R"
}

extension Int {
    // a true modulo, negative numbers will be rounded up
    func mod(by: Int) -> Int {
        var val = self % by
        if val < 0 {
            val += by
        }
        return val
    }
}

let COMBO_REGEX = /(L|R)([0-9]+)/

class Dial {
    var value: Int
    let size: Int
    let range: Range<Int>
    
    init(startPos: Int, size: Int) {
        self.size = size
        self.value = startPos
        self.range = 0..<size
    }
    
    // returns how many times zero was passed
    func rotate(delta: Int, direction: Direction) -> Int {
        var adjustedDelta = delta
        if direction == .left {
            adjustedDelta *= -1
        }
        
        let oldValue = self.value
        self.value += adjustedDelta
        
        let crossing = direction == .left ? self.value...(oldValue - 1) : (oldValue + 1)...self.value
        
        var zeroCrosses: Int = 0
        if crossing.contains(0) {
            zeroCrosses += 1
        }
        
        zeroCrosses += abs(self.value) / self.size
        
        self.value = self.value.mod(by: self.size)
        
        return zeroCrosses
    }
}

func process() {
    var zeroVisits: Int = 0
    let dial = Dial(startPos: 50, size: 100)
    for line in lines {
        guard let match = line.wholeMatch(of: COMBO_REGEX) else {
            print("CANT MATCH \(line)")
            exit(1)
        }
        let direction = Direction(rawValue: String(match.output.1))!
        let value = Int(match.output.2)!
        
        let crossedZero = dial.rotate(delta: value, direction: direction)
        if !PART_TWO && dial.value == 0 {
            zeroVisits += 1
        } else if PART_TWO {
            zeroVisits += crossedZero
        }
    }
    
    print("Zero Visits: \(zeroVisits)")
}

process()
