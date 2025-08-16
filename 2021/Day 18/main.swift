//
//  main.swift
//  Day 18
//
//  Created by Lucas Kellar on 8/13/25.
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

struct SnailfishUnit: Equatable {
    let level: Int
    let number: Int
    
    func withLevel(_ newLevel: Int) -> SnailfishUnit {
        return SnailfishUnit(level: newLevel, number: self.number)
    }
}

typealias SnailfishNumber = [SnailfishUnit]

extension String {
    mutating func popFirst() -> Character? {
        guard !self.isEmpty else {
            return nil
        }
        let char = self.removeFirst()
        return char
    }
}

let numbers: [SnailfishNumber] = lines.map { SnailfishNumber($0) }

extension SnailfishNumber {
    init(_ initialStr: String) {
        var level: Int = 0
        var str = initialStr
        var entries: [SnailfishUnit] = []
        while let char = str.popFirst() {
            if char == "[" {
                level += 1
            } else if char == "]" {
                level -= 1
            } else if let number = char.wholeNumberValue {
                entries.append(SnailfishUnit(level: level, number: number))
            } else if char == "," {
                continue
            } else {
                print("UNEXPECTED CHAR: \(char)")
                exit(1)
            }
        }
        self = entries
    }
    
    func add(to rhs: SnailfishNumber) -> SnailfishNumber {
        var entries: [SnailfishUnit] = []
        for entry in self {
            entries.append(entry.withLevel(entry.level + 1))
        }
        for entry in rhs {
            entries.append(entry.withLevel(entry.level + 1))
        }
        return entries
    }
    
    func explode() -> SnailfishNumber? {
        for index in 0..<(self.count - 1) {
            let level = self[index].level
            let nextLevel = self[index + 1].level
            // if not equal they aren't pair
            guard level == nextLevel else {
                continue
            }
            if level >= 5 {
                var entries: [SnailfishUnit] = []
                if index > 0 {
                    entries.append(contentsOf: self[..<(index - 1)])
                    let newLeftNumber = self[index - 1].number + self[index].number
                    entries.append(SnailfishUnit(level: self[index - 1].level, number: newLeftNumber))
                }
                entries.append(SnailfishUnit(level: level - 1, number: 0))
                if index < (self.count - 2) {
                    let newRightNumber = self[index + 1].number + self[index + 2].number
                    entries.append(SnailfishUnit(level: self[index + 2].level, number: newRightNumber))
                    entries.append(contentsOf: self[(index + 3)...])
                }
                return entries
            }
        }
        return nil
    }
    
    func split() -> SnailfishNumber? {
        for index in 0..<self.count {
            let level = self[index].level
            let value = self[index].number
            if value >= 10 {
                var entries: [SnailfishUnit] = []
                entries.append(contentsOf: self[..<index])
                
                entries.append(SnailfishUnit(level: level + 1, number: value / 2))
                
                if value.isMultiple(of: 2) {
                    entries.append(SnailfishUnit(level: level + 1, number: value / 2))
                } else {
                    entries.append(SnailfishUnit(level: level + 1, number: value / 2 + 1))
                }
                
                entries.append(contentsOf: self[(index + 1)...])
                return entries
            }
        }
        return nil
    }
    
    func reduce() -> SnailfishNumber {
        var current = self
        while true {
            if let exploded = current.explode() {
                current = exploded
            } else if let split = current.split() {
                current = split
            } else {
                return current
            }
        }
    }
    
    var magnitude: Int {
        var current = self
        while current.count > 1 {
            for index in 0..<(current.count - 1) {
                let level = current[index].level
                let nextLevel = current[index + 1].level
                // if not equal they aren't pair
                guard level == nextLevel else {
                    continue
                }
                var entries: [SnailfishUnit] = []
                entries.append(contentsOf: current[..<index])
                let newNumber = current[index].number * 3 + current[index + 1].number * 2
                entries.append(SnailfishUnit(level: level - 1, number: newNumber))
                entries.append(contentsOf: current[(index+2)...])
                current = entries
                break
            }
        }
        return current[0].number
    }
}

func partOne() -> Int {
    var current = numbers[0]
    for number in numbers[1...] {
        current = current.add(to: number)
        current = current.reduce()
    }
    return current.magnitude
}

func partTwo() -> Int {
    var maxSoFar = 0
    for outer in 0..<numbers.count {
        for inner in 0..<numbers.count {
            guard inner != outer else {
                continue
            }
            let sum = numbers[outer].add(to: numbers[inner])
            maxSoFar = max(maxSoFar, sum.reduce().magnitude)
        }
    }
    return maxSoFar
}

if PART_TWO {
    print("Maximum Magnitude of sum of two numbers: \(partTwo())")
} else {
    print("Sum Magnitude: \(partOne())")
}
