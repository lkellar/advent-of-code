//
//  main.swift
//  Day 4
//
//  Created by Lucas Kellar on 12/5/23.
//

import Foundation

let path = CommandLine.arguments[1]

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0.split(separator: ":", maxSplits: 1)[1]) }

var copies = Array(repeating: 1, count: lines.count)

var points = 0;
for (index, line) in lines.enumerated() {
    var winners = Set<Int>()
    let splits = line.split(separator: "|", maxSplits: 1);
    for winner in splits[0].split(separator: " ") {
        winners.insert(Int(winner.trimmingCharacters(in: .whitespaces))!)
    }
    
    var card_total = 0;
    var matches = 0;
    for number in splits[1].split(separator: " ") {
        if winners.contains(Int(number.trimmingCharacters(in: .whitespaces))!) {
            if card_total == 0 {
                card_total = 1
            } else {
                card_total *= 2
            }
            matches += 1;
        }
    }
    
    for card_num in (index + 1)..<(index+matches + 1) {
        copies[card_num] += copies[index];
    }
    
    points += card_total
}

print("Total Points: \(points)")
print("Total Cards: \(copies.reduce(0, +))")
