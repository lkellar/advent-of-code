//
//  main.swift
//  Day 2
//
//  Created by Lucas Kellar on 12/4/23.
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

let cubes = ["red": 12, "green": 13, "blue": 14]

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

var total = 0
var total_power = 0
for line in lines {
    let id = line.split(separator: ":", maxSplits: 1)[0].split(separator: " ", maxSplits: 1)[1]
    let rounds = line.split(separator: ":", maxSplits: 1)[1].split(separator: ";")
    var impossible = false;
    var mins = ["red": 0, "green": 0, "blue": 0]
    for round in rounds {
        for group in round.split(separator: ",") {
            let pair = group.trimmingCharacters(in: .whitespaces).split(separator: " ", maxSplits: 1)
            // dangerous to use ! I know but it's not meant to be run more than once lol
            let word = String(pair[1])
            let count = Int(pair[0])!
            if cubes[word]! < count {
                impossible = true;
            }
            if mins[word]! < count {
                mins[word] = count
            }
        }
    }
    
    if !impossible {
        total += Int(id)!
    }
    
    total_power += (mins["red"]! * mins["green"]! * mins["blue"]!)
}

print("Sum of Possible Game IDs: \(total)")
print("Sum of Power: \(total_power)")
