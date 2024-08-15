//
//  main.swift
//  Advent of Code 2023
//
//  Created by Lucas Kellar on 12/2/23.
//

import Foundation

let path = "input.txt"

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

var PART_TWO = false
let arguments = CommandLine.arguments
if arguments.contains("two") {
    PART_TWO = true
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }
let words = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9]
var total = 0

for line in lines {
    var firsto: Int? = nil;
    var lasto: Int? = nil;
    for index_int in 0..<line.count {
        let index = line.index(line.startIndex, offsetBy: index_int)
        let char = line[index]
        if let num = char.wholeNumberValue {
            if firsto == nil {
                firsto = num
            }
            lasto = num
        } else if PART_TWO {
            for word in words.keys {
                if (index_int + word.count > line.count) {
                    continue
                }
                let end = line.index(index, offsetBy: word.count)
                if line[index..<end] == word {
                    if firsto == nil {
                        firsto = words[word]
                    }
                    lasto = words[word]
                }
            }
        }
    }
    if let firsto = firsto, let lasto = lasto {
        total += firsto * 10 + lasto
    }
    
}
print(total)




