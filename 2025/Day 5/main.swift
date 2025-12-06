//
//  main.swift
//  Day 5
//
//  Created by Lucas Kellar on 12/6/25.
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

var ranges: [ClosedRange<Int>] = []
var ids: [Int] = []

for line in lines {
    let splits = line.split(separator: "-")
    if splits.count == 2{
        ranges.append(Int(splits[0])!...Int(splits[1])!)
    } else {
        ids.append(Int(splits[0])!)
    }
}

extension ClosedRange {
    func merge(with: ClosedRange) -> ClosedRange {
        return Swift.min(self.lowerBound, with.lowerBound)...Swift.max(self.upperBound, with.upperBound)
    }
}

func consolidateRanges() {
    var change = false
    repeat {
        change = false
        for outerIndex in 0..<ranges.count {
            if change == true {
                break
            }
            for innerIndex in (outerIndex + 1)..<ranges.count {
                if ranges[outerIndex].overlaps(ranges[innerIndex]) {
                    ranges[outerIndex] = ranges[outerIndex].merge(with: ranges[innerIndex])
                    ranges.remove(at: innerIndex)
                    change = true
                    break
                }
            }
        }
    } while change == true
}

func partTwo() {
    let total = ranges.reduce(0) {
        $0 + $1.count
    }
    
    print("Total Fresh Ingredients: \(total)")
}

func partOne() {
    let total = ids.count { id in
        ranges.contains { range in
            range.contains(id)
        }
    }

    print("Total Fresh Ingredients: \(total)")
}

consolidateRanges()

if PART_TWO {
    partTwo()
} else {
    partOne()
}
