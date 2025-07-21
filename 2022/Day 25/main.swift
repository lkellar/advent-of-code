//
//  main.swift
//  Day 25
//
//  Created by Lucas Kellar on 7/20/25.
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

func toDecimal(snafu: String) -> Int {
    var total: Int = 0
    for char in snafu {
        total *= 5
        switch char {
        case "2":
            total += 2
        case "1":
            total += 1
        case "-":
            total -= 1
        case "=":
            total -= 2
        case "0":
            continue
        default:
            print("Unknown char: \(char)")
            exit(1)
        }
    }
    return total
}

func toSnafu(decimal: Int) -> String {
    var result = ""
    var current = decimal
    // if the final one needs a leading number
    var negativeCarry = false
    while current > 0 {
        let remainder = current % 5
        switch remainder {
        case 4:
            result += negativeCarry ? "0" : "-"
            negativeCarry = true
        case 3:
            result += negativeCarry ? "-" : "="
            negativeCarry = true
        case 2:
            if negativeCarry {
                result += "="
            } else {
                result += "2"
                negativeCarry = false
            }
        case 1:
            result += negativeCarry ? "2" : "1"
            negativeCarry = false
        case 0:
            result += negativeCarry ? "1" : "0"
            negativeCarry = false
        default:
            print("Impossible to get remainder of \(remainder)")
            exit(1)
        }
        current /= 5
    }
    if negativeCarry {
        result += "1"
    }
    return String(result.reversed())
}

/*for i in 1..<20 {
    print("\(i) -> \(toSnafu(decimal: i))")
}*/

/*for i in [10,15,20,2022,12345,314159265] {
    print("\(i) -> \(toSnafu(decimal: i))")
}*/

func compute() ->  String {
    let total = lines.reduce(into: 0) { result, next in
        result += toDecimal(snafu: next)
    }
    return toSnafu(decimal: total)
}

print("Sum of SNAFUs: \(compute())")
