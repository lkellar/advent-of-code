//
//  main.swift
//  Day 10
//
//  Created by Lucas Kellar on 12/10/25.
//
// Was going to solve with a linear programming solver but got some inspiration from a more interesting solution at
// https://old.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/

import Foundation
import DequeModule
import Algorithms

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

struct Button {
    let lights: [Int]
    
    init(buttonStr: String) {
        let start = buttonStr.index(buttonStr.startIndex, offsetBy: 1)
        let end = buttonStr.index(buttonStr.endIndex, offsetBy: -1)
        self.lights = buttonStr[start..<end].split(separator: ",").map { Int($0)! }
    }
}

struct Machine: Hashable, Equatable {
    let joltage: [Int]
    
    init(lights: Int) {
        let zeroes = Array(repeating: 0, count: lights)
        self.joltage = zeroes
    }
    
    init(machineStr: String) {
        var next = machineStr.index(machineStr.startIndex, offsetBy: 1)
        let end = machineStr.index(machineStr.endIndex, offsetBy: -1)
        
        var local: [Int] = []
        while next != end {
            let char: Character = machineStr[next]
            switch char {
            case "#":
                local.append(1)
            case ".":
                local.append(0)
            default:
                print("Unknown char: \(char)")
                exit(1)
            }
            next = machineStr.index(after: next)
        }
        self.joltage = local
    }
    
    init(numericStr: String) {
        self.joltage = numericStr
            .trimmingCharacters(in: .punctuationCharacters) // trim brackets
            .split(separator: ",") // get rid of commas
            .map { Int($0)! } // turn each into integers
    }
    
    init(joltage: [Int]) {
        self.joltage = joltage
    }
    
    var lights: [Int] {
        return self.joltage.map { $0 % 2 }
    }
    
    func press(with: Button) -> Machine {
        var copy = self.joltage
        for pos in with.lights {
            copy[pos] += 1
        }
        return Machine(joltage: copy)
    }
    
    func exceeds(other: Machine) -> Bool {
        assert(self.lights.count == other.lights.count)
        
        for idx in 0..<self.lights.count {
            if self.lights[idx] > other.lights[idx] {
                return true
            }
        }
        
        return false
    }
    
    var zero: Machine {
        return Machine(lights: self.lights.count)
    }
    
    var description: String {
        return self.lights.map { String($0) }.joined(separator: ", ")
    }
    
    func subtract(other: Machine) -> Machine {
        assert(self.joltage.count == other.joltage.count)
        var copy = self.joltage
        for idx in 0..<other.joltage.count {
            copy[idx] -= other.joltage[idx]
        }
        return Machine(joltage: copy)
    }
}
class Round {
    var buttonCombinations: [[Int] : [[Button]]] = [:]
    var cache: [Machine: Int] = [:]
    let lightCount: Int
    init(buttons: [Button], lightCount: Int) {
        self.lightCount = lightCount
        for combo in buttons.combinations(ofCount: 0...buttons.count) {
            var machine = Machine(lights: lightCount)
            for button in combo {
                machine = machine.press(with: button)
            }
            let lights = machine.lights
            if self.buttonCombinations[lights] != nil {
                self.buttonCombinations[lights]!.append(combo)
            } else {
                self.buttonCombinations[lights] = [combo]
            }
        }
    }
    
    func partOne(target: Machine) -> Int? {
        assert(target.lights == target.joltage)
        
        guard let combos = self.buttonCombinations[target.lights] else {
            print("CANT FIND COMBOS")
            exit(1)
        }
        
        return combos.map { $0.count }.min()!
    }
    
    // part two
    func findMinimumPresses(target: Machine) -> Int? {
        if let result = self.cache[target] {
            return result
        }
        
        if target.joltage.allSatisfy({ $0 == 0 }) {
            return 0
        }
        let lights = target.lights
        guard let combos = self.buttonCombinations[lights] else {
            return nil
        }
        
        var minPresses: Int? = nil
        for combo in combos {
            var testMachine = Machine(lights: self.lightCount)
            for button in combo {
                testMachine = testMachine.press(with: button)
            }
            let diff = target.subtract(other: testMachine)
            guard diff.joltage.allSatisfy({ $0 >= 0}) else {
                continue
            }
            
            assert(diff.joltage.allSatisfy({$0 % 2 == 0}))
            
            let halved = Machine(joltage: diff.joltage.map { $0 / 2 })
            guard let half_presses = findMinimumPresses(target: halved) else {
                continue
            }
            
            let total = combo.count + half_presses * 2
            if minPresses == nil {
                minPresses = total
            } else {
                minPresses = min(total, minPresses!)
            }
        }
        self.cache[target] = minPresses
        return minPresses
    }
}

var total = 0

for line in lines {
    let splits = Array(line.split(separator: " ")).map { String($0) }
    var machine: Machine
    if PART_TWO {
        machine = Machine(numericStr: splits.last!)
    } else {
        machine = Machine(machineStr: splits[0])
    }
    var buttons: [Button] = []
    for split in splits[1..<(splits.count - 1)] {
        buttons.append(Button(buttonStr: split))
    }
    let round = Round(buttons: buttons, lightCount: machine.joltage.count)
    if PART_TWO {
        guard let result = round.findMinimumPresses(target: machine) else {
            print("Could not find match")
            exit(1)
        }
        total += result
    } else {
        guard let result = round.partOne(target: machine) else {
            print("Could not find match")
            exit(1)
        }
        total += result
    }
}

print("Fewest minimum presses: \(total)")
