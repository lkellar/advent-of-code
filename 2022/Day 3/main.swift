//
//  main.swift
//  Day 3
//
//  Created by Lucas Kellar on 8/15/24.
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

extension Character {
    var priority: Int {
        if self.isUppercase {
            return Int(self.asciiValue! - Character("A").asciiValue!) + 27
        } else {
            return Int(self.asciiValue! - Character("a").asciiValue!) + 1
        }
    }
}

func compute() -> Int {
    var total = 0
    for line in lines {
        guard line.count % 2 == 0 else {
            print("Rucksack compartment sizes are not equal")
            exit(1)
        }
        let sliceSize = line.count / 2
        let front = Set(line.prefix(sliceSize))
        let back = Set(line.suffix(sliceSize))

        let overlap = front.intersection(back)
        guard overlap.count == 1 else {
            print("Unexpected overlap size: \(overlap.count)")
            exit(1)
        }
        total += overlap.first!.priority
    }
    return total
}

print("Total Priorities: \(compute())")