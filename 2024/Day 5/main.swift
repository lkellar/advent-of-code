//
//  main.swift
//  Day 5
//
//  Created by Lucas Kellar on 12/5/24.
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

// keep empty subsequences so we know where rules stop and books begin
let lines = contents.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { String($0) }
guard let dividingIndex = lines.firstIndex(of: "") else {
    print("where is the blank linr")
    exit(1)
}

// for every key, none of its vals may come after
var rules: [Int: Set<Int>] = [:]

for line in lines[..<dividingIndex] {
    let bits = line.split(separator: "|")
    let key = Int(bits[1])!
    let val = Int(bits[0])!
    if rules[key] == nil {
        rules[key] = Set([val])
    } else {
        rules[key]!.insert(val)
    }
}

// part two: invalid order if an lhs comes before rhs and rhs is supposed to come before lhs
let sortPredicate: (_ lhs: Int, _ rhs: Int) -> Bool = { lhs, rhs in
    if let rule = rules[rhs] {
        if rule.contains(lhs) {
            return true
        }
    }
    return false
}

func validSequence(_ seq: [Int]) -> Bool {
    // don't check last one because there are no rules about something coming after it
    for index in 0..<seq.count - 1 {
        let key = seq[index]
        let vals = seq[index...]
        // if there are vals coming after that CAN'T come after, break
        if let rule = rules[key] {
            if !rule.isDisjoint(with: vals) {
                return false
            }
        }
    }
    return true
}

func partTwo(seqs: [[Int]]) {
    var total = 0
    for seq in seqs {
        let sorted = seq.sorted(by: sortPredicate)
        total += sorted[Int(sorted.count / 2)]
    }
    print("Sum of Middle of Correct Sequences: \(total)")
}

var total = 0
var invalidSequences: [[Int]] = []
for line in lines[(dividingIndex + 1)...] {
    if line.isEmpty {
        continue
    }
    let seq = line.split(separator: ",").map { Int($0)! }
    if validSequence(seq) {
        // divide hopefully odd count by 2 and floor it to get middle element
        total += seq[Int(seq.count / 2)]
    } else {
        invalidSequences.append(seq)
    }
}

if PART_TWO {
    partTwo(seqs: invalidSequences)
} else {
    print("Total Valid Middles: \(total)")
}
