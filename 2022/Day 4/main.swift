//
//  main.swift
//  Day 4
//
//  Created by Lucas Kellar on 8/16/24.
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

extension ClosedRange {
    // fully overlaps another range
    func embraces(_ other: ClosedRange) -> Bool {
        return self.lowerBound <= other.lowerBound && self.upperBound >= other.upperBound
    }
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let rangePairs: [(ClosedRange, ClosedRange)] = lines.map {
    let splits = $0.split(separator: ",", maxSplits: 1).map { $0.split(separator: "-",maxSplits: 1).map { Int($0)! }}
    return (splits[0][0]...splits[0][1], splits[1][0]...splits[1][1])
}

func partOne() -> Int {
    var total = 0
    for pair in rangePairs {
        if pair.0.embraces(pair.1) || pair.1.embraces(pair.0) {
            total += 1
        }
    }
    return total
}

func partTwo() -> Int {
    var total = 0
    for pair in rangePairs {
        if pair.0.overlaps(pair.1) {
            total += 1
        }
    }
    return total
}

print("Total Overlaps: \(partOne())")
print("Any Overlaps: \(partTwo())")
