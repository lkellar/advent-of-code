//
//  main.swift
//  Day 21
//
//  Created by Lucas Kellar on 5/20/25.
//

import Foundation

let path = CommandLine.arguments[1]

var STARTING_DEPTH = 2
if CommandLine.arguments.contains("two") {
    STARTING_DEPTH = 25
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

let primary_keypad_adjacency: [Character: [Character: Character]] = [
    "0": ["^": "2", ">": "A"],
    "A": ["<": "0", "^": "3"],
    "1": [">": "2", "^": "4"],
    "2": ["<": "1", "^": "5",">": "3", "v": "0"],
    "3": ["<": "2", "^": "6","v": "A"],
    "4": ["v": "1", ">": "5","^": "7"],
    "5": ["v": "2", "<": "4",">": "6", "^": "8"],
    "6": ["v": "3", "<": "5", "^": "9"],
    "7": ["v": "4", ">": "8"],
    "8": ["<": "7", "v": "5",">": "9"],
    "9": ["<": "8", "v": "6"]
]

// top left is 0,0
let primary_locations: [Character: (Int, Int)] = [
    "0": (1,3),
    "A": (2,3),
    "1": (0,2),
    "2": (1,2),
    "3": (2,2),
    "4": (0,1),
    "5": (1,1),
    "6": (2,1),
    "7": (0,0),
    "8": (1,0),
    "9": (2,0)
]

enum ArrowKey: Character {
    case left = "<"
    case down = "v"
    case right = ">"
    case up = "^"
    case activate = "A"
}

let arrowPaths: [ArrowKey: [ArrowKey: [String]]] = [
    .activate: [.activate: [""], .up: ["<"], .down: ["<v", "v<"], .left: ["v<<", "<v<"], .right: ["v"]],
    .left: [.activate: [">>^", ">^>"], .up: [">^"], .down: [">"], .left: [""], .right: [">>"]],
    .down: [.activate: [">^", "^>"], .up: ["^"], .down: [""], .left: ["<"], .right: [">"]],
    .right: [.activate: ["^"], .up: ["<^", "^<"], .down: ["<"], .left: ["<<"], .right: [""]],
    .up: [.activate: [">"], .up: [""], .down: ["v"], .left: ["v<"], .right: [">v", "v>"]]
]

func generateNumberPaths(from: Character, to: Character) -> [String] {
    let fromLocation = primary_locations[from]!
    let toLocation = primary_locations[to]!
    let deltaY = toLocation.1 - fromLocation.1
    let deltaX = toLocation.0 - fromLocation.0
    
    guard deltaX != 0 || deltaY != 0 else {
        return ["A"]
    }
    
    let yKey: ArrowKey = deltaY > 0 ? .down : .up
    let xKey: ArrowKey = deltaX > 0 ? .right : .left
    if deltaX == 0 {
        return [String(repeating: yKey.rawValue, count: abs(deltaY)) + "A"]
    } else if deltaY == 0 {
        return [String(repeating: xKey.rawValue, count: abs(deltaX)) + "A"]
    }
    
    var results: [String] = []
    if let xNext = primary_keypad_adjacency[from]?[xKey.rawValue] {
        for result in generateNumberPaths(from: xNext, to: to) {
            results.append(String(xKey.rawValue) + result)
        }
    }
    if let yNext = primary_keypad_adjacency[from]?[yKey.rawValue] {
        for result in generateNumberPaths(from: yNext, to: to) {
            results.append(String(yKey.rawValue) + result)
        }
    }
    
    return results
}

func computeShortestPathLength(code: String) -> Int {
    var lastChar: Character = "A"
    var paths: [String] = [""]
    for char in Array(code) {
        let potentialPaths = generateNumberPaths(from: lastChar, to: char)
        paths = paths.flatMap { path in
            potentialPaths.map { path + $0}
        }
        lastChar = char
    }
    return paths.map { computeArrowCost(path: $0, depth: STARTING_DEPTH) }.min()!
}

struct CacheKey: Hashable {
    let from: ArrowKey
    let to: ArrowKey
    let depth: Int
}

func computeArrowCost(path: String, depth: Int) -> Int {
    var last: ArrowKey = .activate
    var total = 0
    for char in path {
        guard let next = ArrowKey(rawValue: char) else {
            print("UNKNWON ARROW KEY")
            exit(1)
        }
        total += getShortestArrowPathCost(from: last, to: next, depth: depth)
        last = next
    }
    
    return total
}

// cache from/to/depth -> cost
var memo: [CacheKey: Int] = [:]

func getShortestArrowPathCost(from: ArrowKey, to: ArrowKey, depth: Int) -> Int {
    let key = CacheKey(from: from, to: to, depth: depth)
    if let res = memo[key] {
        return res
    }
    if (depth == 1) {
        let answer = arrowPaths[from]![to]!.min { a,b in a.count < b.count }!.count + 1
        memo[key] = answer
        return answer
    }

    let paths: [String] = arrowPaths[from]![to]!
    var shortest: Int = Int.max
    for path in paths {
        var total = 0
        var last: ArrowKey = .activate
        for char in path {
            guard let next = ArrowKey(rawValue: char) else {
                print("INVALID ARROW KEY")
                exit(1)
            }
            total += getShortestArrowPathCost(from: last, to: next, depth: depth - 1)
            last = next
        }
        total += getShortestArrowPathCost(from: last, to: .activate, depth: depth - 1)
        if total < shortest {
            shortest = total
        }
    }
    memo[key] = shortest
    return shortest
}

var total = 0
for line in lines {
    let pathLength = computeShortestPathLength(code: line)
    let noAIndex = line.index(line.endIndex, offsetBy: -2)
    let codeInt = Int(line[...noAIndex])!
    
    let complexity = codeInt * pathLength
    print("\(pathLength) * \(codeInt)")
    total += complexity
}

print("Total: \(total)")


