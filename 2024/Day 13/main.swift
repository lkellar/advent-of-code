//
//  main.swift
//  Day 13
//
//  Created by Lucas Kellar on 12/13/24.
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

// where a,b is one row and c,d is the other
func determinant(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Double {
    return Double(a*d - b*c)
}

let PART_TWO_SCALE = 10000000000000

func solveMachine(_ ax: Int, _ ay: Int, _ bx: Int, _ by: Int, _ tx: Int, _ ty: Int) -> (Int, Int)? {
    let denominator = determinant(ax, ay, bx, by)
    guard denominator != 0 else {
        return nil
    }
    let x = determinant(tx, bx, ty, by) / denominator
    // only whole numbers and max at 100
    guard x == floor(x) else {
        return nil
    }
    
    let y = determinant(ax, tx, ay, ty) / denominator
    
    guard y == floor(y) else {
        return nil
    }
    
    return (Int(x), Int(y))
}

let VALUE_REGEX = /X[\+=]([0-9]+), Y[\+=]([0-9]+)/

var total = 0
for index in stride(from: 0, to: lines.count, by: 3) {
    let buttonA = lines[index].firstMatch(of: VALUE_REGEX)!
    let buttonB = lines[index + 1].firstMatch(of: VALUE_REGEX)!
    let target = lines[index + 2].firstMatch(of: VALUE_REGEX)!
    
    if let answer = solveMachine(Int(buttonA.output.1)!, Int(buttonA.output.2)!, Int(buttonB.output.1)!, Int(buttonB.output.2)!, Int(target.output.1)! + (PART_TWO ? PART_TWO_SCALE : 0), Int(target.output.2)! + (PART_TWO ? PART_TWO_SCALE : 0)) {
        total += answer.0 * 3 + answer.1
    }
}

print("Total Cost: \(total)")
