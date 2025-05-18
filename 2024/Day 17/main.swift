//
//  main.swift
//  Day 17
//
//  Created by Lucas Kellar on 12/21/24.
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

let initialRegisters = lines[0..<3].map { Int($0.split(separator: ": ")[1])! }

var regA = initialRegisters[0]
var regB = initialRegisters[1]
var regC = initialRegisters[2]

var instrPointer = 0

let program = lines[3].split(separator: ": ")[1].split(separator: ",").map { Int($0)! }

enum Opcode: Int {
    case adv = 0
    case bxl = 1
    case bst = 2
    case jnz = 3
    case bxc = 4
    case out = 5
    case bdv = 6
    case cdv = 7
}

func comboOperand(_ operand: Int) -> Int {
    switch operand {
    case 0,1,2,3:
        return operand
    case 4:
        return regA
    case 5:
        return regB
    case 6:
        return regC
    default:
        print("Combo Operand: \(operand) not recognized")
        exit(1)
    }
}

func reset(overrideA: Int = initialRegisters[0]) {
    regA = overrideA
    regB = initialRegisters[1]
    regC = initialRegisters[2]
    instrPointer = 0
}

func compute() -> [Int] {
    var output: [Int] = []
    while instrPointer < (program.count - 1) {
        if let result = iterate() {
            output.append(result)
        }
    }
    
    return output
}

func iterate() -> Int? {
    var output: Int? = nil
    let opcode = Opcode(rawValue: program[instrPointer])!
    let operand = program[instrPointer + 1]
    // default is to bump pointer by two, some instructions override that
    var bumpPointer = true
    
    switch opcode {
    case .adv:
        let denom = Int(pow(Double(2), Double(comboOperand(operand))))
        // integer division
        regA = regA/denom
    case .bxl:
        regB ^= operand
    case .bst:
        regB = comboOperand(operand) % 8
    case .jnz:
        guard regA != 0 else {
            break
        }
        bumpPointer = false
        instrPointer = operand
    case .bxc:
        regB ^= regC
    case .out:
        output = comboOperand(operand) % 8
    case .bdv:
        let denom = Int(pow(Double(2), Double(comboOperand(operand))))
        regB = regA/denom
    case .cdv:
        let denom = Int(pow(Double(2), Double(comboOperand(operand))))
        regC = regA/denom
    }
    
    if bumpPointer {
        instrPointer += 2
    }
    
    return output
}

func partTwoExecuteStep(a: Int) -> Int {
    var b = a % 8
    b = b ^ 1
    let c = a >> b;
    b = b ^ 4
    b = b ^ c
    return b % 8
}

func partTwoExecute(a startA: Int) -> [Int] {
    var a = startA
    var output: [Int] = []
    while a > 0 {
        output.append(partTwoExecuteStep(a: a))
        a = a >> 3;
    }
    return output
}

enum ComparisonOutcome {
    case wrong
    case partial
    case complete
}

func comparePotential(potential: [Int]) -> ComparisonOutcome {
    let reverseProgram = Array(program.reversed())
    let reversePotential = Array(potential.reversed())
    for index in 0..<reversePotential.count {
        guard reverseProgram[index] == reversePotential[index] else {
            return .wrong
        }
    }
    if reversePotential.count == reverseProgram.count {
        return .complete
    } else {
        return .partial
    }
}

func partTwo() -> Int {
    var potentialAnswers: [Int] = [0]
    var recordLength = 0;
    while true {
        var freshAnswers: [Int] = []
        for octum in 0..<8 {
            for potentialAnswer in potentialAnswers {
                let testA = potentialAnswer + octum
                let potential = partTwoExecute(a: testA)
                guard potential.count >= recordLength else {
                    continue
                }
                if potential.count > recordLength {
                    recordLength = potential.count
                }
                let result = comparePotential(potential: potential)
                if result == .complete {
                    return testA * 0o10
                } else if result == .partial {
                    freshAnswers.append(testA)
                }
            }
        }
        if freshAnswers.isEmpty {
            print("NOT FOUND")
            exit(1)
        }
        potentialAnswers = freshAnswers.map { $0 * 0o10 }
    }
}

extension Int {
    var asOctal: String {
        var output: [String] = []
        var copy = self
        while copy > 0 {
            output.append(String(copy % 8))
            copy /= 8
        }
        output.append("0")
        return output.reversed().joined(separator: " ")
    }
}

if PART_TWO {
    print("Smallest A: \(partTwo())")
} else {
    print("Program Output: \(compute().map { String($0) }.joined(separator: ","))")
}
