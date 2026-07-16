//
//  main.swift
//  Day 5
//
//  Created by Lucas Kellar on 7/16/26.
//

import Foundation

let path = CommandLine.arguments[1]

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


func parsePass(pass: String) -> Int {
    var range = 0..<128
    var passIdx = pass.startIndex
    for _ in 0..<7 {
        let delta = range.count / 2
        switch pass[passIdx] {
        case "F":
            range = (range.lowerBound)..<(range.lowerBound + delta)
        case "B":
            range = (range.lowerBound + delta)..<(range.upperBound)
        default:
            print("Unknown char \(pass[passIdx])")
            exit(1)
        }
        passIdx = pass.index(after: passIdx)
    }
    let rowId = range.lowerBound
    range = 0..<8
    for _ in 0..<3 {
        let delta = range.count / 2
        switch pass[passIdx] {
        case "L":
            range = (range.lowerBound)..<(range.lowerBound + delta)
        case "R":
            range = (range.lowerBound + delta)..<(range.upperBound)
        default:
            print("Unknown char \(pass[passIdx])")
            exit(1)
        }
        passIdx = pass.index(after: passIdx)
    }
    let colId = range.lowerBound
    return rowId * 8 + colId
}

let seatIds = lines.map { parsePass(pass: $0) }.sorted()

print("Highest Pass: \(seatIds.last!)")

for idx in 1..<(seatIds.count) {
    let last = seatIds[idx - 1]
    let curr = seatIds[idx]
    guard curr - last == 1 else {
        print("Missing seat: \(curr - 1)")
        exit(0)
    }
}
