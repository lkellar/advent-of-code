//
//  main.swift
//  Day 3
//
//  Created by Lucas Kellar on 8/15/24.
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

extension Character {
    var priority: Int {
        if self.isUppercase {
            return Int(self.asciiValue! - Character("A").asciiValue!) + 27
        } else {
            return Int(self.asciiValue! - Character("a").asciiValue!) + 1
        }
    }
}

func partOne() -> Int {
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

func partTwo() -> Int {
    var total = 0
    guard lines.count % 3 == 0 else {
        print("Rucksacks are not in groups of 3")
        exit(1)
    }
    for index in stride(from: 0, to: lines.count, by: 3) {
        let intersec = Set(lines[index]).intersection(Set(lines[index+1])).intersection(Set(lines[index+2]))
        guard intersec.count == 1 else {
            print("Intersection has count \(intersec.count)")
            exit(1)
        }
        total += intersec.first!.priority
    }
    return total
}

print("Part One | Total Priorities: \(partOne())")
print("Part Two | Intersect Priorities: \(partTwo())")
