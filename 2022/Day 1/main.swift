//
//  main.swift
//  Advent of Code 2022
//
//  Created by Lucas Kellar on 8/14/24.
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

let lines = contents.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { String($0) }

func getTopCalorics(howMany: Int) -> [Int] {
    var topCalorics: Set<Int> = []
    var currentCalories = 0
    
    func checkTopCaloric(_ value: Int) {
        guard topCalorics.count == howMany else {
            topCalorics.insert(value)
            return
        }
        guard let lowest = topCalorics.min() else {
            print("Somehow topCalorics has \(topCalorics.count) entries but no min")
            exit(1)
        }
        if lowest < value {
            topCalorics.remove(lowest)
            topCalorics.insert(value)
        }
    }
    
    for line in lines {
        if line.isEmpty {
            checkTopCaloric(currentCalories)
            currentCalories = 0
        } else {
            currentCalories += Int(line)!
        }
    }
    checkTopCaloric(currentCalories)
    return topCalorics.sorted(by: >)
}


let topCalorics = getTopCalorics(howMany: 3)
print("Part One: \(topCalorics.first!) calories")

print("Part Two: \(topCalorics.reduce(0, +)) calories total for top three")
