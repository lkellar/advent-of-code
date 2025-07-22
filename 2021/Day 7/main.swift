//
//  main.swift
//  Day 7
//
//  Created by Lucas Kellar on 7/21/25.
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

let positions = contents.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: ",").compactMap { Int($0) }

let minX = positions.min()!
let maxX = positions.max()!

func compute() -> Int {
    var leastFuel = Int.max
    for x in minX...maxX {
        var localFuelCost = 0
        for position in positions {
            let dist = abs(x - position)
            if PART_TWO {
                // triangular number
                localFuelCost += (dist*(dist + 1)) / 2
            } else {
                localFuelCost += dist
            }
        }
        leastFuel = min(leastFuel, localFuelCost)
    }
    return leastFuel
}

print("Least Fuel Required: \(compute())")
