//
//  main.swift
//  Day 2
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

let FORWARD_REGEX = /forward ([0-9]+)/
let UP_REGEX = /up ([0-9]+)/
let DOWN_REGEX = /down ([0-9]+)/

func partOne() -> Int {
    var x = 0
    var y = 0
    for line in lines {
        if let match = line.wholeMatch(of: FORWARD_REGEX) {
            x += Int(match.output.1)!
        } else if let match = line.wholeMatch(of: UP_REGEX) {
            y -= Int(match.output.1)!
        } else if let match = line.wholeMatch(of: DOWN_REGEX) {
            y += Int(match.output.1)!
        }
    }
    return x * y
}

func partTwo() -> Int {
    var x = 0
    var y = 0
    var aim = 0
    for line in lines {
        if let match = line.wholeMatch(of: FORWARD_REGEX) {
            let deltaX = Int(match.output.1)!
            x += deltaX
            y += aim * deltaX
        } else if let match = line.wholeMatch(of: UP_REGEX) {
            aim -= Int(match.output.1)!
        } else if let match = line.wholeMatch(of: DOWN_REGEX) {
            aim += Int(match.output.1)!
        }
    }
    return x * y
}

if PART_TWO {
    print("Multiplied final position: \(partTwo())")
} else {
    print("Multiplied final position: \(partOne())")
}
