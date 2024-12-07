//
//  main.swift
//  Day 7
//
//  Created by Lucas Kellar on 12/7/24.
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

enum Operator {
    case Plus
    case Times
    case Concatenate
}

let operators: [Operator] = [.Plus, .Times] + (PART_TWO ? [.Concatenate] : [])

struct OperatorIterator: IteratorProtocol {
    var index = 0
    let size: Int
    let upperBound: Int
    init(size: Int) {
        self.upperBound = Int(pow(Double(operators.count), Double(size)))
        self.size = size
    }

    mutating func next() -> [Operator]? {
        guard index < upperBound else {
            return nil
        }
        var curr = index
        var output: [Operator] = []
        while curr > 0 {
            output.append(operators[curr % operators.count])
            curr /= operators.count
        }
        let outputCount = output.count
        if outputCount < size {
            for _ in outputCount..<size {
                output.append(operators.first!)
            }
        }
        index += 1
        return output.reversed()
            
    }
}

func compute(terms: [Int], ops: [Operator]) -> Int {
    var stack = terms.first!
    for (index, term) in terms[1...].enumerated() {
        let op = ops[index]
        switch op {
        case .Plus:
            stack += term
        case .Times:
            stack *= term
        case .Concatenate:
            stack = Int(String(stack) + String(term))!
        }
    }
    return stack
}

func solvePossible(target: Int, terms: [Int]) -> Bool {
    let opCount = terms.count - 1
        
    var iterator = OperatorIterator(size: opCount)
    while let perm = iterator.next() {
        if compute(terms: terms, ops: perm) == target {
            return true
        }
    }
    return false
}

var total = 0
for line in lines {
    let splits = line.split(separator: ":", maxSplits: 1)
    let target = Int(splits.first!)!
    let terms = splits[1].trimmingCharacters(in: .whitespaces).split(separator: " ").map { Int($0)! }
    
    if solvePossible(target: target, terms: terms) {
        total += target
    }
}

print("Total Calibration Result: \(total)")
