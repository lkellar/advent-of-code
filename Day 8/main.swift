//
//  main.swift
//  Day 8
//
//  Created by Lucas Kellar on 12/9/23.
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

let instruc = lines[0]

let map = lines[1...].reduce(into: [String: (left: String, right: String)](), {result, line in
    let key = line.split(separator: " = ", maxSplits: 1)[0]
    let first = line.split(separator: "(", maxSplits: 1)[1].split(separator: ",", maxSplits: 1)[0]
    let second = line.split(separator: ", ", maxSplits: 1)[1].split(separator: ")", maxSplits: 1)[0]
    
    result[String(key)] = (left: String(first), right: String(second))
})

var current: [String] = []
if PART_TWO {
    current = map.keys.filter { $0.hasSuffix("A") }
} else {
    current.append("AAA")
}
var index = instruc.startIndex
var steps = 0

var satisfyPredicate: (String) -> Bool = {
    $0 == "ZZZ"
}
if PART_TWO {
    satisfyPredicate = { $0.hasSuffix("Z") }
}

// https://en.wikipedia.org/wiki/Euclidean_algorithm#Implementations
func gcd(_ first: Int, _ second: Int) -> Int {
    var a = first
    var b = second
    while b != 0 {
        let temp = b
        b = a % b
        a = temp
    }
    return a
}

// https://en.wikipedia.org/wiki/Least_common_multiple#Using_the_greatest_common_divisor
func lcm(_ a: Int, _ b: Int) -> Int {
    return a * (b / gcd(a,b))
}

var repeats = (0..<current.count).reduce(into: [Int: [Int]](), {result, now in
    result[now] = []
})

// either we're at Z for all of them, or we have enough data to do the math version
while !current.allSatisfy(satisfyPredicate) && !(!repeats.isEmpty && repeats.values.allSatisfy {$0.count >= 3}) {
    let left = instruc[index] == Character("L")
    for index in 0..<current.count {
        if satisfyPredicate(current[index]) {
            repeats[index]!.append(steps)
            //print("Index: \(index) | Steps: \(steps) | Current: \(current[index])")
        }
        if left {
            current[index] = map[current[index]]!.left
        } else {
            current[index] = map[current[index]]!.right
        }
    }
    
    index = instruc.index(index, offsetBy: 1)
    if index == instruc.endIndex {
        index = instruc.startIndex
    }
    steps += 1
    
}

if PART_TWO && !current.allSatisfy(satisfyPredicate) {
    steps = repeats.values.reduce(1, {result, vals in
        // amount between repeats once a loop has been established
        let tourSize = vals[2] - vals[1]
        return lcm(result, tourSize)
    })
}



print("Total Steps: \(steps)")

