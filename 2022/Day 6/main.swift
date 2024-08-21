//
//  main.swift
//  Day 6
//
//  Created by Lucas Kellar on 8/20/24.
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

let MARKER_SIZE = PART_TWO ? 14 : 4

func compute() -> Int? {
    var buffer: [Character] = []
    for (index, char) in contents.enumerated() {
        var removalCount = 0
        for (b_index, b_char) in buffer.enumerated() {
            if char == b_char {
                if removalCount > 0 {
                    print("WHOA")
                }
                removalCount = b_index + 1
            }
        }
        buffer.removeFirst(removalCount)
        buffer.append(char)
        if buffer.count == MARKER_SIZE {
            return index + 1
        }
    }
    return nil
}

print("Characters until end of marker: \(compute()?.description ?? "nil")")
