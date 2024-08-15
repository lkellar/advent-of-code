//
//  main.swift
//  Day 15
//
//  Created by Lucas Kellar on 12/23/23.
//

import Foundation
import OrderedCollections
let path = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let contents: String
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let chunks = contents.split(whereSeparator: \.isNewline)[0].split(separator: ",").map { String($0) }

func hash(char: Character, current: Int) -> Int {
    var val = current
    val += Int(char.asciiValue!)
    val *= 17
    return val % 256
}

func hash(str: String) -> Int {
    var total = 0
    for char in str {
        total = hash(char: char, current: total)
    }
    return total
}

func part_two() -> Int {
    var boxes = [Int: OrderedDictionary<String, Int>]()
    for chunk in chunks {
        let bits = chunk.split(whereSeparator: {$0 == "=" || $0 == "-"})
        let label = String(bits[0])
        let box = hash(str: label)
        if boxes[box] == nil {
            boxes[box] = OrderedDictionary<String, Int>()
        }
        if chunk.contains("-") {
            boxes[box]?.removeValue(forKey: label)
        } else {
            boxes[box]![label] = Character(String(bits[1])).wholeNumberValue
        }
    }
    var total = 0
    for (key, value) in boxes {
        var slot = 1
        for focal in value.values {
            total += slot * focal * (key + 1)
            slot += 1
        }
    }
    return total
}

if PART_TWO {
    print(part_two())
} else {
    var total = 0
    for chunk in chunks {
        total += chunk.reduce(0) {
            return hash(char: $1, current: $0)
        }
    }
    print(total)
}

