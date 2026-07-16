//
//  main.swift
//  Day 6
//
//  Created by Lucas Kellar on 7/16/26.
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

let groups = contents.split(separator: "\n\n").map { String($0) }

var total = 0
for group in groups {
    let lines = group.split(whereSeparator: \.isNewline)
    var questions: Set<Character>?
    for line in lines {
        let next = Set(line)
        guard let existing = questions else {
            questions = next
            continue
        }
        if PART_TWO {
            questions = existing.intersection(next)
        } else {
            questions = existing.union(next)
        }
    }
    total += questions?.count ?? 0
}

print("Sum of Questions Answered: \(total)")

