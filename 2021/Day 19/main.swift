//
//  main.swift
//  Day 19
//
//  Created by Lucas Kellar on 6/25/26
//

import Foundation
import Algorithms

let path = CommandLine.arguments[1]

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let chunks = contents.split(separator: "\n\n").map {
    String($0)
        .split(whereSeparator: \.isNewline)
        .map { String($0) }
 }

func generateRotationVectors() -> [Vector] {
    var combos: [[Int]] = []
    for a in [1,-1] {
        for b in [2,-2] {
            for c in [3, -3] {
                combos.append([a,b,c])
            }
        }
    }
    return combos.flatMap { $0.permutations() }
}

let rotationVectors = generateRotationVectors()

struct Coord: Hashable, AdditiveArithmetic {
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    static let zero: Coord = Coord(0, 0, 0)
    
    let x: Int
    let y: Int
    let z: Int
    
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    // actually squared dist
    func dist(from: Coord) -> Int {
        return Int(pow(Double(self.x) - Double(from.x), 2))
                + Int(pow(Double(self.y) - Double(from.y), 2))
                + Int(pow(Double(self.z) - Double(from.z), 2))
    }
    
    // actually squared dist
    func manhattanDist(from: Coord) -> Int {
        return abs(self.x - from.x)
                + abs(self.y - from.y)
                + abs(self.z - from.z)
    }
    
    // get by 1-indexed index (1 gets x, 2 gets y, -1 gets -x, etc)
    func getByIdx(idx: Int) -> Int {
        switch idx {
        case 1:
            return self.x
        case -1:
            return -self.x
        case 2:
            return self.y
        case -2:
            return -self.y
        case 3:
            return self.z
        case -3:
            return -self.z
        default:
            print("Unrecongized idx: \(idx)")
            exit(1)
        }
    }
    
    func rotate(vector: Vector) -> Coord {
        assert(vector.count == 3)
        return Coord(
            self.getByIdx(idx: vector[0]),
            self.getByIdx(idx: vector[1]),
            self.getByIdx(idx: vector[2])
        )
    }
}

typealias Map = Set<Coord>
typealias CoordPair = (Coord, Coord)
typealias Vector = [Int]

var scanners: [[Coord]] = []

for chunk in chunks {
    // ignore first line (scanner number)
    var scanner: [Coord] = []
    for idx in 1..<(chunk.count) {
        let nums = chunk[idx]
            .split(separator: ",")
            .map { Int(String($0))! }
        scanner.append(Coord(nums[0], nums[1], nums[2]))
    }
    scanners.append(scanner)
}

func calculateDists(coords: [Coord]) -> Set<Int> {
    var dists: Set<Int> = []
    for outIdx in 0..<(coords.count - 1) {
        let outer = coords[outIdx]
        for inIdx in (outIdx + 1)..<(coords.count) {
            let sqDist = outer.dist(from: coords[inIdx])
            dists.insert(sqDist)
        }
    }
    
    return dists
}

// input how many 90 degree CLOCKWISE turns should be done
func rotateMap(_ input: Map, vector: Vector) -> Map {
    return Set(input.map { $0.rotate(vector: vector) })
}


let dists: [Set<Int>] = scanners.map { calculateDists(coords: $0) }

var canonMap: Map = Set(scanners[0])
var canonDists: Set<Int> = dists[0]
var scannerLocations: Set<Coord> = [Coord(0,0,0)]

var remainingIndexes = Set(1..<(scanners.count))


func findOverlapCoords(map: Map, target: Int) -> CoordPair? {
    let mapArr = Array(map)
    for outerIdx in 0..<(mapArr.count - 1) {
        for innerIdx in (outerIdx + 1)..<(mapArr.count) {
            let dist = mapArr[outerIdx].dist(from: mapArr[innerIdx])
            if dist == target {
                return (mapArr[outerIdx], mapArr[innerIdx])
            }
        }
    }
    return nil
}

// return the rotation
func rotateTilTarget(_ coords: CoordPair, targetDelta: Coord) -> Vector? {
    let curDelta = coords.0 - coords.1
    for vector in rotationVectors {
        if curDelta.rotate(vector: vector) == targetDelta {
            return vector
        }
    }
    return nil
}

func findShiftVector(canon: Map, other: [Coord]) -> Coord? {
    for inner in canon {
        for outer in other {
            let delta = outer - inner
            let shiftedOuter = Set(other.map { $0 - delta })
            if shiftedOuter.intersection(canon).count >= 12 {
                return delta
            }
        }
    }
    return nil
}


func mergeMaps(canon: inout Map, other: [Coord], overlap: Set<Int>) -> Bool {
    let otherSet = Set(other)
    var rotationVectors: Set<Vector> = []
    for dist in overlap {
        guard let canonCoords = findOverlapCoords(map: canon, target: dist) else {
            continue
        }
        guard let otherCoords = findOverlapCoords(map: otherSet, target: dist) else {
            continue
        }
        let canonDelta = canonCoords.0 - canonCoords.1
        guard let vector = rotateTilTarget(otherCoords, targetDelta: canonDelta) else {
            continue
        }
        rotationVectors.insert(vector)
    }
    
    for vector in rotationVectors {
        let rotatedOther = otherSet.map { $0.rotate(vector: vector) }
        guard let shiftVector = findShiftVector(canon: canon, other: rotatedOther) else {
            continue
        }
        
        // part two, keep track of where scanners are
        scannerLocations.insert(shiftVector)
        
        let shiftedMap = rotatedOther.map { $0 - shiftVector }
        
        canon.formUnion(shiftedMap)
        return true
    }
    
    return false
}

var changed = false
repeat {
    changed = false
    for idx in remainingIndexes {
        let overlap = canonDists.intersection(dists[idx])
        if mergeMaps(canon: &canonMap, other: scanners[idx], overlap: overlap) {
            changed = true
            canonDists = canonDists.union(dists[idx])
            remainingIndexes.remove(idx)
            print("Merged \(idx) with canon")
            break
        }
    }
} while changed == true

print("Canon Map Size: \(canonMap.count)")

// PART TWO
var maxManhattanDist: Int = 0
let scannerArr = Array(scannerLocations)
for outerIdx in 0..<(scannerArr.count - 1) {
    let outer = scannerArr[outerIdx]
    for innerIdx in (outerIdx + 1)..<(scannerArr.count) {
        maxManhattanDist = max(maxManhattanDist, outer.manhattanDist(from: scannerArr[innerIdx]))
    }
}

print("Max Manhattan Distance between Scanners: \(maxManhattanDist)")
