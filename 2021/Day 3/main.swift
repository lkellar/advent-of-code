//
//  main.swift
//  Day 3
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

let lines = contents.split(whereSeparator: \.isNewline).map { Array($0) }

// assumes all numbers are same length
let height = lines.count
let width = lines[0].count

// is the 1 bit more common for a given x
func isOneMoreCommon(x: Int, candidates: [[Character]]) -> Bool {
    let count = (0..<(candidates.count)).count { candidates[$0][x] == "1" }
    return count * 2 >= candidates.count
}

func partOne() -> Int {
    var gamma = 0
    var epsilon = 0
    for x in 0..<width {
        gamma *= 2
        epsilon *= 2
        if isOneMoreCommon(x: x, candidates: lines) {
            gamma += 1
        } else {
            epsilon += 1
        }
    }

    return gamma * epsilon
}

func filterRound(x: Int, candidates: [[Character]]) -> [[Character]] {
    guard candidates.count > 1 else {
        return candidates
    }

    let oneMoreCommon = isOneMoreCommon(x: x, candidates: candidates)
    return candidates.filter { oneMoreCommon ? $0[x] == "1" : $0[x] == "0" }
}

func partTwo() -> Int {
    var oxygenCandidates = lines
    var co2Candidates = lines
    for x in 0..<width {
        if oxygenCandidates.count > 1 {
            let oneMoreCommon = isOneMoreCommon(x: x, candidates: oxygenCandidates)
            oxygenCandidates = oxygenCandidates.filter { oneMoreCommon ? $0[x] == "1" : $0[x] == "0" }
        }

        if co2Candidates.count > 1 {
            let oneMoreCommon = isOneMoreCommon(x: x, candidates: co2Candidates)
            co2Candidates = co2Candidates.filter { oneMoreCommon ? $0[x] == "0" : $0[x] == "1" }
        }
    }
    guard let oxygenRating = oxygenCandidates.first else {
        print("Oxygen Rating missing")
        exit(1)
    }

    guard let co2Rating = co2Candidates.first else {
        print("CO2 Rating missing")
        exit(1)
    }

    return Int(String(oxygenRating), radix: 2)! * Int(String(co2Rating), radix: 2)!
}

if PART_TWO {
    print("Life Support Rating: \(partTwo())")
} else {
    print("Sub Power Consumption: \(partOne())")
}
