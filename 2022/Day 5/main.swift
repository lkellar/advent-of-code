//
//  main.swift
//  Day 5
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let moveRegex = /([0-9]+)/

var crateHeight = -1

for (index, line) in lines.enumerated() {
   if line.starts(with: "move") {
       crateHeight = index - 2
       break
   }
}

let crateCount = lines[crateHeight + 1].split(whereSeparator: \.isWhitespace).count

guard crateHeight != -1 else {
    print("Didn't find crate height")
    exit(1)
}

class CargoShip {
    var stacks: [[Character]]
    init (crateCount: Int) {
        // avoid all the off by one stuff by just having a dummy crate up front
        stacks = Array(repeating: Array(), count: crateCount + 1)
    }
    
    func add(crate: Character, dest: Int) {
        stacks[dest].append(crate)
    }
    
    func move(from: Int, to: Int, howMany: Int) {
        if PART_TWO {
            let temp = Array(stacks[from].suffix(howMany))
            stacks[to].append(contentsOf: temp)
            stacks[from].removeLast(howMany)
        } else {
            for _ in 0..<howMany {
                guard let temp = stacks[from].popLast() else {
                    print("Stack \(from + 1) is empty!")
                    exit(1)
                }
                stacks[to].append(temp)
            }
        }
    }
    
    func getTops() -> String {
        var answer = ""
        for stack in stacks {
            if let last = stack.last {
                answer += String(last)
            }
        }
        return answer
    }
}

func compute() {
    let ship = CargoShip(crateCount: crateCount)
    
    for line_index in stride(from: crateHeight, through: 0, by: -1) {
        let line = lines[line_index]
        var crate = 1
        for col_index in stride(from: 1, to: line.count, by: 4) {
            let index = line.index(line.startIndex, offsetBy: col_index)
            let char = line[index]
            if char != " " {
                ship.add(crate: char, dest: crate)
            }
            crate += 1
        }
    }
    
    for line_index in stride(from: crateHeight + 2, to: lines.count, by: 1) {
        let matches = lines[line_index].matches(of: moveRegex)
        let count = Int(matches[0].output.1)!
        let src = Int(matches[1].output.1)!
        let to = Int(matches[2].output.1)!
        ship.move(from: src, to: to, howMany: count)
    }
    
    print("Tops: \(ship.getTops())")
}

compute()
