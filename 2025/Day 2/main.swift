//
//  main.swift
//  Day 2
//
//  Created by Lucas Kellar on 12/2/25.
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

// just one line, split by commas
let lines = contents
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .split(separator: ",")
    .map { String($0) }

var ranges: [ClosedRange<Int>] = []

for line in lines {
    let splits = line.split(separator: "-").map{ Int(String($0))! }
    ranges.append(splits[0]...splits[1])
}

// 1 backreference
let PART_ONE_REGEX = /^([0-9]+)\1$/
// at least one back reference
let PART_TWO_REGEX = /^([0-9]+)\1+$/

var total = 0
for range in ranges {
    for num in range {
        let str = String(num)
        if str.contains(PART_TWO ? PART_TWO_REGEX : PART_ONE_REGEX) {
            total += num
        }
    }
}

print("Total Invalid IDs: \(total)")
