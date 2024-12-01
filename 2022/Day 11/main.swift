//
//  main.swift
//  Day 11
//
//  Created by Lucas Kellar on 8/27/24.
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

let chunks = contents.split(separator: "\n\n").map { String($0) }

class Monkey {
    var inspectCount: Int = 0
    var items: [Int]
    var incomingItems: [Int] = []
    private let op: (Int) -> Int
    let test: (Int) -> Int
    
    init(items: [Int], op: @escaping (Int) -> Int, test: @escaping (Int) -> Int) {
        self.items = items
        self.op = op
        self.test = test
    }
    
    func flushItems() {
        /*self.items = self.incomingItems
        self.incomingItems = []*/
        self.items = []
    }
    
    func addItem(_ item: Int) {
        //self.incomingItems.append(item)
        self.items.append(item)
    }
    
    func inspect(_ item: Int) -> Int {
        inspectCount += 1
        return op(item)
    }
}

enum Operator: String {
    case Plus = "+"
    case Minus = "-"
    case Multiply = "*"
    case Divide = "/"
    
    func compute(_ first: Int, _ second: Int) -> Int {
        switch self {
        case .Plus:
            return first + second
        case .Minus:
            return first - second
        case .Multiply:
            return first * second
        case .Divide:
            return first / second
        }
    }
}

let monkeys: [Monkey] = chunks.map { chunk in
    let lines = chunk.split(whereSeparator: \.isNewline)
    let items = lines[1].split(separator: ":", maxSplits: 1)[1].split(separator: ",").map {
        Int($0.trimmingCharacters(in: CharacterSet.whitespaces))!
    }
    let operations = lines[2].split(separator: "new = old ")[1].split(separator: " ")
    let opSymbol = Operator(rawValue: String(operations[0]))!
    let opValue = operations[1]
    
    let op: (Int) -> Int = {opSymbol.compute($0, opValue == "old" ? $0 : Int(opValue)!) / (PART_TWO ? 1 : 3) }
    
    let testValue = Int(lines[3].split(whereSeparator: \.isWhitespace).last!)!
    let trueDest = Int(lines[4].split(whereSeparator: \.isWhitespace).last!)!
    let falseDest = Int(lines[5].split(whereSeparator: \.isWhitespace).last!)!
    
    let test: (Int) -> Int = {($0 % testValue == 0) ? trueDest : falseDest}
    
    return Monkey(items: items, op: op, test: test)
}

func processRound() {
    for monkey in monkeys {
        for item in monkey.items {
            let newItem = monkey.inspect(item)
            let dest = monkey.test(newItem)
            monkeys[dest].addItem(newItem)
        }
        monkey.flushItems()
    }
    /*for monkey in monkeys {
        monkey.flushItems()
    }*/
}

func findTwoMaxes(_ data: [Int]) -> (Int, Int) {
    var first: Int? = nil
    var second: Int? = nil
    for item in data {
        guard let localFirst = first else {
            first = item
            continue
        }
        if item > localFirst {
            second = localFirst
            first = item
            continue
        }
        guard let localSecond = second else {
            second = item
            continue
        }
        if item > localSecond {
            second = item
        }
    }
    
    return (first!, second!)
}

func partOne() {
    for _ in 0..<(PART_TWO ? 10000 : 20)  {
        processRound()
    }
    let maxes = findTwoMaxes(monkeys.map {$0.inspectCount} )
    print("Inspections Multiplied: \(maxes.0 * maxes.1)")
}

partOne()
