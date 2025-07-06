//
//  main.swift
//  Day 20
//
//  Created by Lucas Kellar on 7/4/25.
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
let SIZE = lines.count

class DataUnit: Equatable {
    static func == (lhs: DataUnit, rhs: DataUnit) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID = UUID()
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
}

var datums: [DataUnit] = []

let DECRYPTION_KEY = 811589153

for line in lines {
    var value = Int(line)!
    if PART_TWO {
        value *= DECRYPTION_KEY
    }
    datums.append(DataUnit(value: value))
}

let originalDatums = datums

func mix() {
    for datum in originalDatums {
        let startIndex = datums.firstIndex { $0 == datum }!
        let shiftAmount = datum.value
        var endIndex = (startIndex + shiftAmount) % (SIZE - 1)
        if endIndex < 0 {
            endIndex += (SIZE - 1)
        }
        if startIndex == endIndex {
            continue
        }
        let unit = datums.remove(at: startIndex)
        datums.insert(unit, at: endIndex)
    }
}


func compute() -> Int {
    var total = 0
    let startIndex: Int = Int(datums.firstIndex { $0.value == 0 }!)
    for index in 1...3 {
        total += datums[(startIndex + (index * 1000)) % SIZE].value
    }
    return total
}

if PART_TWO {
    for _ in 0..<10 {
        mix()
    }
} else {
    mix()
}
print("Coordinate Sum: \(compute())")


