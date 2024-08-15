//
//  main.swift
//  Day 22
//
//  Created by Lucas Kellar on 7/8/24.
//

import Foundation
import HeapModule

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

var map: [[[Int?]]] = [[[]]] 

// inclusive region
func regionEmpty(x1: Int, y1: Int, z1: Int, x2: Int, y2: Int, z2: Int) -> Bool {
    guard x1 >= 0 && x2 >= 0 && y1 >= 0 && y2 >= 0 && z1 >= 1 && z2 >= 1 else {
        return false
    }
    for x in x1...x2 {
        for y in y1...y2 {
            for z in z1...z2 {
                if map[x][y][z] != nil {
                    return false
                }
            }
        }
    }
    return true
}

struct Brick {
    let index: Int

    let startX: Int
    let startY: Int
    var startZ: Int

    let endX: Int
    let endY: Int
    var endZ: Int

    // brick indices that this one would land and depend on
    var supportedBy: Set<Int> = []
    // brick indicies that land on this one and that this one supports. Basically inverse of above
    var supports: Set<Int> = []

    mutating func shiftBrickDownwardIfPossible() -> Bool {
        guard startZ > 1 && endZ > 1 else {
            return false
        }
        var shift = 0
        while regionEmpty(x1: startX, y1: startY, z1: startZ - shift - 1, x2: endX, y2: endY, z2: startZ - shift - 1) {
            shift += 1
        }
        guard shift > 0 else {
            return false
        }

        for x in startX...endX {
            for y in startY...endY {
                for z in (endZ - shift + 1)...endZ {
                    map[x][y][z] = nil
                }
                for z in (startZ - shift)...(endZ - shift) {
                    map[x][y][z] = self.index
                }
            }
        }

        startZ -= shift
        endZ -= shift

        return true
    }

    init(_ str: String, index: Int) {
        let splits = str.split(separator: "~")
        let starts = splits[0].split(separator: ",").map { Int($0) }
        startX = starts[0]!
        startY = starts[1]!
        startZ = starts[2]!

        let ends = splits[1].split(separator: ",").map { Int($0) }
        endX = ends[0]!
        endY = ends[1]!
        endZ = ends[2]!

        self.index = index
    }
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }
var bricks = lines.enumerated().map { Brick($1, index: $0) }

var maxX = 0
var maxY = 0
var maxZ = 1

for brick in bricks {
    maxX = max(maxX, brick.endX)
    maxY = max(maxY, brick.endY)
    maxZ = max(maxZ, brick.endZ)
}

// x -> y -> z and then brick index
map = Array(repeating: Array(repeating: Array(repeating: nil, count: maxZ + 1), count: maxY + 1), count: maxX + 1)

for (index, brick) in bricks.enumerated() {
    // ranges are inclusive
    for x in brick.startX...brick.endX {
        for y in brick.startY...brick.endY {
            for z in brick.startZ...brick.endZ {
                guard map[x][y][z] == nil else {
                    print("Position at (\(x), \(y), \(z)) is already taken. Exiting")
                    exit(1)
                }
                map[x][y][z] = index
            }
        }
    }
}

var stable = false
var rounds = 0
while !stable {
    rounds += 1
    stable = true
    for index in 0..<bricks.count {
        // returns true if a shift was possible
        if bricks[index].shiftBrickDownwardIfPossible() {
            stable = false
        }
    }
}

print("\(rounds) rounds to stabilize")

for (index, brick) in bricks.enumerated() {
    // (brickIndex, zLevel)
    var parents: Set<Int> = []
    for x in brick.startX...brick.endX {
        for y in brick.startY...brick.endY {
            // should be nothing at z = 0
            if let parent = map[x][y][brick.startZ - 1] {
                parents.insert(parent)
            }
        }
    }
    bricks[index].supportedBy = parents
    for parent in parents {
        bricks[parent].supports.insert(index)
    }
}

func printMap() {
    // z practically starts at 1
    for z in 1..<map[0][0].count {
        print("z = \(z)")
        for y in 0..<map[0].count {
            var line = ""
            for x in 0..<map.count {
                if let num = map[x][y][z] {
                    line += (String(num) + " ")
                } else {
                    line += ". "
                }
            }
            print(line)
        }

        print()
    }
}

func countSafeToRemove() -> Int {
    var safeCount = 0
    for brick in bricks {
        let dependents: [Brick] = brick.supports.map { bricks[$0] }

        // if everything that this brick supports is supported by more than 1 brick, this brick is safe to remove
        if dependents.allSatisfy({ $0.supportedBy.count > 1 }) {
            safeCount += 1
        }
    }

    return safeCount
}

// a tiny struct that holds a brick and how far up it reaches, so we can remove the bricks that top out the lowest first
struct BrickMarker: Comparable {
    let index: Int
    let endZ: Int

    static func == (lhs: BrickMarker, rhs: BrickMarker) -> Bool {
        return lhs.endZ == rhs.endZ
    }

    static func < (lhs: BrickMarker, rhs: BrickMarker) -> Bool {
        return lhs.endZ < rhs.endZ
    }
}

// how many other bricks would fall if this brick was removed
func whatIfBrickGone(startIndex: Int) -> Int {
    var priorityQueue: Heap<BrickMarker> = [BrickMarker(index: startIndex, endZ: bricks[startIndex].endZ)]
    var seen: Set<Int> = []
    var localBricks = bricks

    var affected = 0
    while let marker = priorityQueue.popMin() {
        let index = marker.index
        guard !seen.contains(index) else {
            continue
        }
        seen.insert(index)

        let brick = localBricks[index]
        if index == startIndex || brick.supportedBy.isEmpty {
            // starting brick isn't counted in this calc
            if index != startIndex {
                affected += 1
            }
            for childIndex in brick.supports {
                localBricks[childIndex].supportedBy.remove(index)
                priorityQueue.insert(BrickMarker(index: childIndex, endZ: bricks[childIndex].endZ))
            }
        }
    }

    return affected
}

if PART_TWO {
    var sumOfAffected = 0
    for index in 0..<bricks.count {
        sumOfAffected += whatIfBrickGone(startIndex: index)
    }
    print("\(sumOfAffected) dependent bricks would fall if every brick was removed.")
} else {
    print("\(countSafeToRemove()) bricks safe to remove")
}