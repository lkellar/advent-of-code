//
//  main.swift
//  Day 3
//
//  Created by Lucas Kellar on 12/3/24.
//

import Foundation

let path = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

var contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

var MUL_REGEX = /mul\(([0-9]+),([0-9]+)\)/
// finds do and don't calls
let DO_DONT_REGEX = /(?:do(?:n't|)\(\))/

if PART_TWO {
    // ranges of where instructions lie
    let instr_ranges = contents.ranges(of: DO_DONT_REGEX)
    // domains of instructions and everything that follows
    var new_ranges: [Range<String.Index>] = []
    for index in 0..<(instr_ranges.count - 1) {
        // extend range from instruction start to start of next instruction
        new_ranges.append(instr_ranges[index].lowerBound..<instr_ranges[index + 1].lowerBound)
    }
    // handle last instruction
    new_ranges.append(instr_ranges.last!.lowerBound..<contents.endIndex)
    // remove ranges in reverse to not invalidate earlier ranges
    for delimiter in new_ranges.reversed() {
        if contents[delimiter].starts(with: "don't()") {
            contents.removeSubrange(delimiter)
        }
    }
}

var total = 0
for match in contents.matches(of: MUL_REGEX) {
    total += Int(match.output.1)! * Int(match.output.2)!
}

print("Sum of Multiplications: \(total)")
