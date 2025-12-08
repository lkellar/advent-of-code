//
//  main.swift
//  Day 8
//
//  Created by Lucas Kellar on 12/8/25.
//

import Foundation
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

let coords = contents.split(whereSeparator: \.isNewline).map { line in
    let splits = line.split(separator: ",").map { Int($0)! }
    return Coord(splits[0], splits[1], splits[2])
}

struct Coord: AdditiveArithmetic, Hashable {
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    static var zero = Coord(0,0,0)
    
    let x: Int
    let y: Int
    let z: Int
    
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var magnitudeSquared: Int {
        return self.x * self.x + self.y * self.y + self.z * self.z
    }
}

var pairs: [(Coord, Coord, Int)] = []
pairs.reserveCapacity((coords.count * (coords.count + 1)) / 2)

for outerIndex in 0..<coords.count {
    let outer = coords[outerIndex]
    for innerIndex in (outerIndex + 1)..<coords.count {
        let inner = coords[innerIndex]
        let dist = (outer - inner).magnitudeSquared
        pairs.append((outer, inner, dist))
    }
}

let pairCount = path == "input.txt" ? 1000 : 10
let topPairs = pairs.sorted { left, right in
    left.2 < right.2
}

// union-find, each with itself
var circuit: [Coord: Coord] = coords.reduce(into: [:]) { res, coord in
    res[coord] = coord
}

// union-find find rep, update as we go
func getRep(_ coord: Coord) -> Coord {
    var seen: [Coord] = []
    var next = coord
    while circuit[next]! != next {
        seen.append(next)
        next = circuit[next]!
    }
    
    // update all to final rep
    for intermediate in seen {
        circuit[intermediate] = next
    }
    
    return next
}

var distinctCircuits = coords.count
var index = 0
for pair in topPairs {
    if !PART_TWO && index >= pairCount {
        break
    }
    let leftRep = getRep(pair.0)
    let rightRep = getRep(pair.1)
    
    index += 1
    
    if leftRep == rightRep {
        continue
    }
    
    circuit[rightRep] = leftRep
    distinctCircuits -= 1
    if PART_TWO && distinctCircuits == 1 {
        print("Last two X coords multiplied: \(pair.0.x * pair.1.x)")
        exit(0)
    }
}
print(distinctCircuits)

var circuitSizes: [Coord: Int] = [:]

for coord in coords {
    let rep = getRep(coord)
    if let current = circuitSizes[rep] {
        circuitSizes[rep] = current + 1
    } else {
        circuitSizes[rep] = 1
    }
}

let topThree = circuitSizes.values.max(count: 3)

print("Top Three Multiplied: \(topThree[0] * topThree[1] * topThree[2])")

print("Distinct Circuits: \(distinctCircuits)")
