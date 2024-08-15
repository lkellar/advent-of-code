//
//  main.swift
//  Day 2
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let scores = ["X": 1, "Y": 2, "Z": 3]

enum Throw: Int {
    case Rock = 1
    case Paper = 2
    case Scissors = 3
}

extension Throw {
    init?(opponent: String) {
        switch opponent {
            case "A": self = .Rock
            case "B": self = .Paper
            case "C": self = .Scissors
            default: return nil
        }
    }
    init?(ours: String) {
        switch ours {
            case "X": self = .Rock
            case "Y": self = .Paper
            case "Z": self = .Scissors
            default: return nil
        }
    }
}

enum WinState: String {
    case Lose = "X"
    case Win = "Z"
    case Draw = "Y"
}

func computePartOneScore(ours: String, oppThrow: Throw) -> Int {
    guard let ourThrow = Throw(ours: ours) else {
        print("\(ours) isn't a valid throw for us")
        exit(1)
    }
    // draw condition
    if ourThrow == oppThrow {
        return ourThrow.rawValue + 3
    }
    // win condition
    if ourThrow == .Rock && oppThrow == .Scissors
    || ourThrow == .Paper && oppThrow == .Rock
    || ourThrow == .Scissors && oppThrow == .Paper {
        return ourThrow.rawValue + 6
    }
    // lose condition
    return ourThrow.rawValue
}

func computePartTwoScore(ours: String, oppThrow: Throw) -> Int {
    guard let winState = WinState(rawValue: ours) else {
        print("\(ours) isn't a valid winstate for us")
        exit(1)
    }
    var score = 0
    if winState == .Win {
        score += 6
    } else if winState == .Draw {
        score += 3
    }
    if oppThrow == .Rock && winState == .Win
    || oppThrow == .Scissors && winState == .Lose
    || oppThrow == .Paper && winState == .Draw {
        score += Throw.Paper.rawValue
    } else if oppThrow == .Paper && winState == .Win
    || oppThrow == .Rock && winState == .Lose
    || oppThrow == .Scissors && winState == .Draw {
        score += Throw.Scissors.rawValue
    } else {
        score += Throw.Rock.rawValue
    }
    
    return score
}

func computeTotals() -> Int {
    var total = 0
    for line in lines {
        let splits: [String] = line.split(separator: " ", maxSplits: 1).map { String($0) }
        guard let oppThrow = Throw(opponent: splits[0]) else {
            print("\(splits[0]) isn't a valid throw for opponent")
            exit(1)
        }
        total += PART_TWO ? computePartTwoScore(ours: splits[1], oppThrow: oppThrow) : computePartOneScore(ours: splits[1], oppThrow: oppThrow)
    }
    return total
}

print("Total: \(computeTotals())")