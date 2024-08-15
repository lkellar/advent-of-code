//
//  main.swift
//  Day 21
//
//  Created by Lucas Kellar on 7/3/24.
//

import Foundation
import DequeModule

let path = CommandLine.arguments[1]
let distArg = Int(CommandLine.arguments[2])!

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

enum Spot: String {
    case start = "S"
    case plot = "."
    case rock = "#"
}

let lines = contents.split(whereSeparator: \.isNewline).map { $0.map { Spot(rawValue: String($0))!} }

let height = lines.count
let width = lines[0].count

let allDirections: Set<Direction> = [.left, .right, .up, .down]

// https://stackoverflow.com/a/41180619/8525240
func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

func getSpot(_ coord: Coord) -> Spot {
    let row = mod(coord.row, height)
    let col = mod(coord.col, width)
    return lines[row][col]
}

enum Direction: Int {
    case right = 0
    case left = 1
    case up = 2
    case down = 3
}

struct Coord: Hashable {
    var row: Int
    var col: Int
    
    func furtherWithDirection(direc: Direction) -> Coord {
        switch direc {
        case .left:
            return Coord(row: row, col: col - 1)
        case .right:
            return Coord(row: row, col: col + 1)
        case .down:
            return Coord(row: row + 1, col: col)
        case .up:
            return Coord(row: row - 1, col: col)
        }
    }
    
    func getValidTwoAwayNeighbors() -> [Coord] {
        let neighbors = getValidNeighbors()
        var doubleNeighbors = Set(neighbors.flatMap {$0.getValidNeighbors()})
        doubleNeighbors.remove(self)
        return Array(doubleNeighbors)
    }
    
    // doesn't do it if there's a rock
    func getValidNeighbors() -> [Coord] {
        return allDirections.map { furtherWithDirection(direc: $0) }.filter {
            (PART_TWO || ($0.row >= 0 && $0.col >= 0 && $0.row < height && $0.col < width))
            && getSpot($0) != .rock
        }
    }
}

struct Primum {
    var earliest_visit: Int? = nil
    
    var visited: Bool {
        return earliest_visit != nil
    }

    func accessible(even: Bool) -> Bool {
        guard let earliest_visit = earliest_visit else {
            return false
        }
        if even {
            return earliest_visit % 2 == 0
        }
        return earliest_visit % 2 == 1
    }
}

var prims: [Coord: Primum] = [:]

var starter: Coord? = nil
for row in 0..<height {
    for col in 0..<width {
        if getSpot(Coord(row: row, col: col)) == .start {
            starter = Coord(row: row, col: col)
        }
    }
}

guard let starter = starter else {
    print("Unable to find start point?")
    exit(1)
}

func countPrimums(even: Bool) -> Int {
    var total = 0
    for item in prims.values {
        if item.accessible(even: even) {
            total += 1
        }
    }
    return total
}

func resetPrims() {
    prims = [:]
}

struct PolyTerm {
    let numeratorTerms: [Double]
    let denominator: Double
    let multiplier: Double
}

func computeTerm(term: PolyTerm, x: Double) -> Double {
    let numerator = term.numeratorTerms.reduce(into: Double(1)) { result, next in
        result = result * (x - next)
    }
    return (numerator / term.denominator) * term.multiplier
}

func computePolynomial(terms: [PolyTerm], x: Double) -> Double {
    return terms.reduce(into: Double(0)) { result, next in
        result += computeTerm(term: next, x: x)
    }
}

func constructPolynomial(data: [(Int, Int)]) -> [PolyTerm] {
    var terms: [PolyTerm] = []
    let allXs = data.map { Double($0.0) }
    for datum in data {
        let localX = Double(datum.0)
        let numerator = allXs.filter { localX != $0 }
        let denominator: Double = allXs.reduce(into: Double(1)) { result, next in
            if localX != next {
                result = result * (localX - next)
            }
        }
        let term = PolyTerm(numeratorTerms: numerator, denominator: denominator, multiplier: Double(datum.1))
        terms.append(term)
    }
    
    return terms
}

func compute(start: Coord, targetDist: Int) -> Int {
    var queue: Deque = [start]
    let even = targetDist % 2 == 0
    if !even {
        queue = Deque(start.getValidNeighbors())
    }
    
    // set initial earliest visits
    queue.forEach { coord in
        prims[coord] = Primum(earliest_visit: even ? 0 : 1)
    }
    while let curr = queue.popFirst() {
        guard let earliest_visit = prims[curr]?.earliest_visit else {
            print("Somehow something in the queue doesn't have an earliest visit")
            exit(1)
        }
        guard earliest_visit < targetDist else {
            continue
        }
        let neighbors = curr.getValidTwoAwayNeighbors().filter {
            (prims[$0]?.visited ?? false) == false
        }
        for neigh in neighbors {
            if prims[neigh] == nil {
                prims[neigh] = Primum()
            }
            prims[neigh]!.earliest_visit = earliest_visit + 2
        }
        queue.append(contentsOf: neighbors)
    }
    
    return countPrimums(even: even)
}

// 5 and 6 didn't work (but like it should haha?)
// 3 worked, which quadratic fitting I guess
let PART_TWO_ITERATIONS = 3

if PART_TWO {
    var points: [(Int, Int)] = []
    let mid = height / 2
    precondition((distArg - mid) % height == 0, "This implementation requires the number of walks to fit neatly into the grid size")
    precondition(height == width, "Assuming square grid")
    for index in stride(from: mid, to: mid+height*PART_TWO_ITERATIONS, by: height) {
        resetPrims()
        let result = compute(start: starter, targetDist: index)
        //print("\(index), \(compute(start: starter, targetDist: index))")
        points.append((index, result))
        
        print("\(index), \(result)")
    }
    let terms = constructPolynomial(data: points)
    let answer = computePolynomial(terms: terms, x: Double(distArg))
    print(Int(answer))

} else {
    print(compute(start: starter, targetDist: distArg))
}

//printMapToFile(path: "/Users/lucas/Downloads/out.txt")
