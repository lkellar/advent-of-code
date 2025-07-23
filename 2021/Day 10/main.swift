//
//  main.swift
//  Day 10
//
//  Created by Lucas Kellar on 7/22/25.
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

let symbolPairs: [Character: Character] = ["(":")", "{": "}", "[": "]", "<": ">"]
let openers = symbolPairs.keys
let symbolScores: [Character: Int] = [")": 3, "]": 57, "}": 1197, ">": 25137]
let incompleteScoreValues: [Character: Int] = [")": 1, "]": 2, "}": 3, ">": 4]

enum ParseResult {
    case invalidCharacter(Character)
    case missingCharacters([Character])
}

func parseLine(line: inout String, expectedEnd: Character?) -> ParseResult {
    var result: [Character] = []
    if let expectedEnd = expectedEnd {
        result = [expectedEnd]
    }
    guard !line.isEmpty else {
        return .missingCharacters(result)
    }
    var nextChar = line.removeFirst()
    while openers.contains(nextChar) {
        let parseResult = parseLine(line: &line, expectedEnd: symbolPairs[nextChar])
        switch parseResult {
        case .invalidCharacter:
            return parseResult
        case .missingCharacters(let missingChars):
            result = missingChars + result
        }
        if line.isEmpty {
            return .missingCharacters(result)
        }
        nextChar = line.removeFirst()
    }
    guard nextChar == expectedEnd else {
        return .invalidCharacter(nextChar)
    }
    return .missingCharacters([])
}

func compute() {
    var corruptedTotal = 0
    var incompleteScores: [Int] = []
    for index in 0..<lines.count {
        var line = lines[index]
        let parseResult = parseLine(line: &line, expectedEnd: nil)
        switch parseResult {
        case .invalidCharacter(let char):
            corruptedTotal += symbolScores[char]!
        case .missingCharacters(let missingChars):
            var total = 0
            for char in missingChars {
                total *= 5
                total += incompleteScoreValues[char]!
            }
            incompleteScores.append(total)
        }
    }
    
    let middleIncompleteScore = incompleteScores.sorted()[incompleteScores.count / 2]
    
    print("Corrupted Score Sum: \(corruptedTotal)")
    print("Middle Incomplete Score: \(middleIncompleteScore)")
}

compute()
