//
//  main.swift
//  Day 10
//
//  Created by Lucas Kellar on 8/22/24.
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

let CYCLES_TO_CHECK = [20, 60, 100, 140, 180, 220]

let HEIGHT = 6
let WIDTH = 40

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

enum Instruction: String {
    case add = "addx"
    case noop = "noop"
}

class Computer {
    var register: Int = 1
    var cycle: Int = 0
    
    var strengthTotal: Int = 0
    
    var lines: [String] = []
    
    private func checkCycleStrength() {
        if CYCLES_TO_CHECK.contains(cycle) {
            strengthTotal += (register * cycle)
            print("Cycle \(cycle): Register at \(register) | Adding \(register * cycle)")
        }
    }
    
    private func computeLetters() {
        let remainder = (cycle - 1) % WIDTH
        if remainder == 0 {
            lines.append("")
        }
        if abs(register - remainder) <= 1 {
            lines[lines.endIndex - 1].append("#")
        } else {
            lines[lines.endIndex - 1].append(".")
        }
    }
    
    private func tick() {
        cycle += 1
        if PART_TWO {
            computeLetters()
        } else {
            checkCycleStrength()
        }
    }
    
    func executeInstruction(instrString: String) {
        tick()
        let splits = instrString.split(separator: " ", maxSplits: 1)
        let instr = Instruction(rawValue: String(splits[0]))!
        let arg = splits.count > 1 ? Int(splits[1]) : nil
        switch instr {
        case .add:
            tick()
            register += arg!
        case .noop:
            break
        }
    }
}

func compute() {
    let comput = Computer()
    for line in lines {
        comput.executeInstruction(instrString: line)
        if comput.cycle >= (WIDTH * HEIGHT) {
            break
        }
    }
    
    if PART_TWO {
        for line in comput.lines {
            print(line)
        }
    } else {
        print("Strenght TOtal: \(comput.strengthTotal)")
    }
}

compute()
