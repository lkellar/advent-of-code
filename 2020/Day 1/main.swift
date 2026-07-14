//
//  main.swift
//  Day 1
//
//  Created by Lucas Kellar on 7/13/26.
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

let lines = contents.split(whereSeparator: \.isNewline).map { Int($0)! }

func partOne() -> Int {
    for outerIdx in 0..<(lines.count - 1) {
        let outer = lines[outerIdx]
        for innerIdx in (outerIdx + 1)..<(lines.count) {
            let inner = lines[innerIdx]
            if outer + inner == 2020 {
                return outer * inner
            }
        }
    }
    print("Can't find answer")
    exit(1)
}

func partTwo() -> Int {
    for outerIdx in 0..<(lines.count - 2) {
        let outer = lines[outerIdx]
        for innerIdx in (outerIdx + 1)..<(lines.count - 1) {
            let inner = lines[innerIdx]
            for evenMoreInnderIdx in (innerIdx + 1)..<lines.count {
                let evenMoreInner = lines[evenMoreInnderIdx]
                if outer + inner + evenMoreInner == 2020 {
                    return outer * inner * evenMoreInner
                }
            }
        }
    }
    print("Can't find answer")
    exit(1)
}

print("Part One: \(partOne())")
print("Part Two: \(partTwo())")
