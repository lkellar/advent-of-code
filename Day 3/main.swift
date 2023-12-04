//
//  I am aware this code is terribly written, but it works haha
//  main.swift
//  Day 3
//
//  Created by Lucas Kellar on 12/4/23.
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

func isSymbol(_ char: Character) -> Bool {
    return !(char.isWholeNumber) && char != "."
}

var adjacents = [String: [Int]]()

var total = 0;
func processGears(current_gears: [(Int, Int)], num: Int) {
    for gear in current_gears {
        let str = String(gear.0) + "-" + String(gear.1)
        if adjacents[str] == nil {
            adjacents[str] = [num]
        } else {
            adjacents[str]?.append(num)
        }
    }
}

for (row, line) in lines.enumerated() {
    var current_number = 0;
    var connected = false;
    var current_gears: [(Int, Int)] = [];
    
    var availableRows = [row]
    if (row != 0) {
        availableRows.append(row - 1)
    }
    if (row < lines.count - 1) {
        availableRows.append(row + 1)
    }

    for (col, char) in line.enumerated() {
        if let digit = char.wholeNumberValue {
            current_number = current_number * 10 + digit
        } else if connected {
            total += current_number
            processGears(current_gears: current_gears, num: current_number)
            current_gears = []
            connected = false
            current_number = 0
        } else if current_number > 0 && !connected {
            current_number = 0
        }
        var availableCols = [col]
        if (col != 0) {
            availableCols.append(col - 1)
        }
        if (col < line.count - 1) {
            availableCols.append(col + 1)
        }
        if !connected && char.isWholeNumber {
            for availRow in availableRows {
                for availCol in availableCols {
                    let local_char = lines[lines.index(lines.startIndex, offsetBy: availRow)][line.index(line.startIndex, offsetBy: availCol)]
                    if isSymbol(local_char) {
                        connected = true
                        if local_char == Character("*") {
                            current_gears.append((availRow, availCol))
                        }
                        break
                    }
                }
                if (connected) {
                    break
                }
            }
        }
    }
    
    if (connected) {
        total += current_number
        processGears(current_gears: current_gears, num: current_number)
        current_gears = []
    }
}

var gear_ratios = 0
for value in adjacents.values {
    if value.count == 2 {
        gear_ratios += (value[0] * value[1])
    }
}


print(total)
print(gear_ratios)
