//
//  main.swift
//  Day 1
//
//  Created by Lucas Kellar on 7/21/25.
//

import Foundation
import Algorithms

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
    return lines.adjacentPairs().count { $0.0 < $0.1 }
}

func partTwo() -> Int {
    return lines.windows(ofCount: 3).adjacentPairs().count { pair in
        let firstSum = pair.0.reduce(0, +)
        let secondSum = pair.1.reduce(0, +)
        return firstSum < secondSum
    }
}

print("Depth Increases: \(partOne())")
print("3-Window Increases: \(partTwo())")
