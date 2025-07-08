//
//  main.swift
//  Day 21
//
//  Created by Lucas Kellar on 7/5/25.
//

import Foundation

import DequeModule

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

let CONSTANT_REGEX = /([a-z]{4}): ([0-9]+)/
let DEPENDENT_REGEX = /([a-z]{4}): ([a-z]{4}) ([\*\/\-\+]) ([a-z]{4})/

enum Operator: String {
    case plus = "+"
    case minus = "-"
    case times = "*"
    case divide = "/"
}

var knownValues: [String: Int] = [:]
var dependents: [String: [String]] = [:]
var monkeys: [String: Monkey] = [:]

struct Monkey {
    let name: String
    let dependencies: [String]
    let dependents: [String]
    let op: Operator?
    let constantValue: Int?
    
    init(name: String, dependencies: [String], dependents: [String], op: Operator) {
        self.name = name
        self.dependencies = dependencies
        self.dependents = dependents
        self.op = op
        self.constantValue = nil
    }
    
    init(name: String, constantValue: Int, dependents: [String]) {
        self.name = name
        self.constantValue = constantValue
        self.dependents = dependents
        self.dependencies = []
        self.op = nil
    }
    
    var value: Int? {
        if let val = constantValue {
            return val
        }
        guard let first = knownValues[dependencies[0]] else {
            return nil
        }
        guard let second = knownValues[dependencies[1]] else {
            return nil
        }
        guard let op = op else {
            print("No op OR constnat value??")
            exit(1)
        }
        switch (op) {
        case .plus:
            return first + second
        case .minus:
            return first - second
        case .times:
            return first * second
        case .divide:
            return first / second
        }
    }
 }


for line in lines {
    guard let match = line.wholeMatch(of: DEPENDENT_REGEX) else {
        continue
    }
    let dependent = String(match.output.1)
    let dependency_one = String(match.output.2)
    let dependency_three = String(match.output.4)
    for dependency in [dependency_one, dependency_three] {
        if dependents[dependency] != nil {
            dependents[dependency]!.append(dependent)
        } else {
            dependents[dependency] = [dependent]
        }
    }
}

var queue: Deque<String> = []

for line in lines {
    if let match = line.wholeMatch(of: CONSTANT_REGEX) {
        let name = String(match.output.1)
        let value = Int(match.output.2)!
        let monkey = Monkey(name: name, constantValue: value, dependents: dependents[name] ?? [])
        monkeys[name] = monkey
        queue.append(name)
    }
    if let match = line.wholeMatch(of: DEPENDENT_REGEX) {
        let name = String(match.output.1)
        let op = Operator(rawValue: String(match.output.3))!
        let dependencies = [match.output.2, match.output.4].map { String($0) }
        let monkey = Monkey(name: name, dependencies: dependencies, dependents: dependents[name] ?? [], op: op)
        monkeys[name] = monkey
    }
}

func computeFirstDependency(monkey: Monkey, resultingValue: Int) -> Int {
    let otherValue = knownValues[monkey.dependencies[1]]!
    switch monkey.op! {
    case .plus:
        return resultingValue - otherValue
    case .minus:
        return resultingValue + otherValue
    case .times:
        return resultingValue / otherValue
    case .divide:
        return resultingValue * otherValue
    }
}

func computeSecondDependency(monkey: Monkey, resultingValue: Int) -> Int {
    let otherValue = knownValues[monkey.dependencies[0]]!
    switch monkey.op! {
    case .plus:
        return resultingValue - otherValue
    case .minus:
        return otherValue - resultingValue
    case .times:
        return resultingValue / otherValue
    case .divide:
        return otherValue / resultingValue
    }
}

func compute() {
    while let next = queue.popFirst() {
        guard knownValues[next] == nil else {
            continue
        }
        let monkey = monkeys[next]!
        guard let value = monkey.value else {
            continue
        }
        knownValues[next] = value
        queue.append(contentsOf: monkey.dependents)
    }
}

func humnInDependencyChain(parent: String) -> Bool {
    if parent == "humn" {
        return true
    }
    let monkey = monkeys[parent]!
    return monkey.dependencies.contains { humnInDependencyChain(parent: $0) }
}

func computeHumn(start: String, requiredValue: Int) -> Int {
    if start == "humn" {
        return requiredValue
    }
    let monkey = monkeys[start]!
    
    if humnInDependencyChain(parent: monkey.dependencies[0]) {
        let nextRequiredValue = computeFirstDependency(monkey: monkey, resultingValue: requiredValue)
        return computeHumn(start: monkey.dependencies[0], requiredValue: nextRequiredValue)
    }
    
    if humnInDependencyChain(parent: monkey.dependencies[1]) {
        let nextRequiredValue = computeSecondDependency(monkey: monkey, resultingValue: requiredValue)
        return computeHumn(start: monkey.dependencies[1], requiredValue: nextRequiredValue)
    }
    
    print("NOT FOUND")
    exit(1)
}

func partTwo() -> Int {
    let monkey = monkeys["root"]!
    
    if humnInDependencyChain(parent: monkey.dependencies[0]) {
        let nextRequiredValue = knownValues[monkey.dependencies[1]]!
        return computeHumn(start: monkey.dependencies[0], requiredValue: nextRequiredValue)
    }
    
    if humnInDependencyChain(parent: monkey.dependencies[1]) {
        let nextRequiredValue = knownValues[monkey.dependencies[0]]!
        return computeHumn(start: monkey.dependencies[1], requiredValue: nextRequiredValue)
    }
    
    print("WHAT NOT FOUND")
    exit(1)
}

compute()
if PART_TWO {
    print("Human Value: \(partTwo())")
} else {
    guard let root = knownValues["root"] else {
        print("ROOT NOT FOUND")
        exit(1)
    }
    print("Root Value: \(root)")
}
