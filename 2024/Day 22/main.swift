//
//  main.swift
//  Day 22
//
//  Created by Lucas Kellar on 5/23/25.
//

import Foundation
import DequeModule

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

struct ChangeSequence: Hashable {
    let first: Int8
    let second: Int8
    let third: Int8
    let fourth: Int8
    
    init(deq: Deque<Int8>) {
        first = deq[0]
        second = deq[1]
        third = deq[2]
        fourth = deq[3]
    }
}

let MOD_24: UInt64 = 0x1000000 - 1
func processNumber(starter: UInt64, iterations: Int) -> UInt64 {
    var number = starter
    for _ in 0..<iterations {
        //var result = number << 6
        var result: UInt64 = number * 64
        number ^= result
        number &= MOD_24
        
        //result = number >> 5
        result = number / 32
        number ^= result
        number &= MOD_24
        
        result = number * 2048
        //result = number << 11
        number ^= result
        number &= MOD_24
    }
    
    return number;
}


let ITERATIONS = 2000
func partOne() {
    var total = 0
    for line in lines {
        total += Int(processNumber(starter: UInt64(line)!, iterations: ITERATIONS))
    }
    print("Total: \(total)")
}

func partTwo() {
    var memo: [[ChangeSequence: UInt8]] = Array(repeating: [:], count: lines.count)
    var index = 0
    for line in lines {
        var lastTens: Deque<Int8> = []
        var number = UInt64(line)!
        var lastTen: Int8 = Int8(number % 10)
        for _ in 0..<ITERATIONS {
            number = processNumber(starter: number, iterations: 1)
            let tensPlace = Int8(number % 10)
            let delta = lastTen - tensPlace
            lastTen = tensPlace
            if lastTens.count == 4 {
                lastTens.removeFirst()
            }
            lastTens.append(delta)
            
            if lastTens.count == 4 {
                let seq = ChangeSequence(deq: lastTens)
                if memo[index][seq] == nil {
                    memo[index][seq] = UInt8(tensPlace)
                }
            }
        }
        index += 1
    }
    
    var resultSet: [ChangeSequence: UInt32] = [:]
    for row in memo {
        for (key, val) in row {
            if let existing = resultSet[key] {
                resultSet[key] = existing + UInt32(val)
            } else {
                resultSet[key] = UInt32(val)
            }
        }
    }
    guard let maximum = resultSet.values.max() else {
        print("NO MAX")
        exit(1)
    }
    print("Max bananansa: \(maximum)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
