//
//  main.swift
//  Day 1
//
//  Created by Lucas Kellar on 12/1/24.
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

let first = lines.map { Int($0.split(whereSeparator: \.isWhitespace).first!)! }.sorted()
let second = lines.map { Int($0.split(whereSeparator: \.isWhitespace).last!)! }.sorted()

func partOne() {
    var total = 0

    for index in 0..<first.count {
        total += abs(first[index] - second[index])
    }

    print("Total Distance: \(total)")
}

func partTwo() {
    // count occurances in second
    var counts: [Int: Int] = [:]
    for item in second {
        counts[item] = (counts[item] ?? 0) + 1
    }
    var total = 0
    for item in first {
        if let occur = counts[item] {
            total += item * occur
        }
    }
    print("Total Similarity Score: \(total)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}

