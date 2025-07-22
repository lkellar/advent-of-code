//
//  main.swift
//  Day 8
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

// amount of segments to be lit up for a value to qualify
let PART_ONE_TARGET_AMOUNTS = [2,3,4,7]

func partOne() -> Int {
    var total = 0
    for line in lines {
        // get values AFTER the divider
        let outputValues = line
            .split(separator: "|")[1]
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .split(separator: " ")
        // 1,4,7, and 8
        total += outputValues.count { PART_ONE_TARGET_AMOUNTS.contains($0.count) }
    }
    return total
}

func processLine(line: String) -> Int {
    let splits = line.split(separator: "|").map { $0.trimmingCharacters(in: CharacterSet.whitespaces).split(separator: " ").map { Set($0) } }
    let baseSet = splits[0]
    var menu: [Set<Character>?] = Array(repeating: nil, count: 10)
    menu[8] = baseSet.first { $0.count == 7 }
    menu[7] = baseSet.first { $0.count == 3 }
    menu[4] = baseSet.first { $0.count == 4 }
    menu[1] = baseSet.first { $0.count == 2 }
    menu[3] = baseSet.first { $0.count == 5 && menu[1]!.isSubset(of: $0) }
    
    menu[9] = baseSet.first { $0.count == 6 && menu[3]!.isSubset(of: $0) }
    menu[6] = baseSet.first { $0.count == 6 && !menu[7]!.isSubset(of: $0) }
    menu[0] = baseSet.first { $0.count == 6 && $0 != menu[6] && $0 != menu[9] }
    
    menu[5] = baseSet.first { $0.count == 5 && $0 != menu[3] && $0.isSubset(of: menu[6]!)}
    menu[2] = baseSet.first { $0.count == 5 && $0 != menu[3] && $0 != menu[5]}
    
    var outputValue = ""
    for digit in splits[1] {
        for index in 0..<10 {
            if menu[index] == digit {
                outputValue += String(index)
            }
        }
    }
    return Int(outputValue)!
}

func partTwo() -> Int {
    var total = 0
    for line in lines {
        total += processLine(line: line)
    }
    return total
}

if PART_TWO {
    print("Sum of output values: \(partTwo())")
} else {
    print("Appearances of 1,4,7,8: \(partOne())")
}
