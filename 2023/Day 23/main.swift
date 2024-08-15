//
//  main.swift
//  Day 23
//
//  Created by Lucas Kellar on 7/8/24.
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

enum Spot: String {
    case path = "."
    case tree = "#"
    case leftSlope = "<"
    case rightSlope = ">"
    case upSlope = "^"
    case downSlope = "v"
    
    var isSlope: Bool {
        return self == .leftSlope || self == .rightSlope || self == .upSlope || self == .downSlope
    }
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
    
    var isJunction: Bool {
        return lines[row][col] != .tree && getValidNeighbors().count >= 3
    }

    var description: String { return "(\(row), \(col))" }
    var graphDescription: String { return "\(row).\(col)" }
    
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
    
    // doesn't do it if there's a rock
    func getValidNeighbors() -> [Coord] {
        var potentialNeighbors: [Coord] = []
        let spot = lines[row][col]
        if PART_TWO {
            potentialNeighbors = allDirections.map { furtherWithDirection(direc: $0) }
        } else {
            switch spot {
            case .leftSlope:
                potentialNeighbors = [furtherWithDirection(direc: .left)]
            case .rightSlope:
                potentialNeighbors = [furtherWithDirection(direc: .right)]
            case .upSlope:
                potentialNeighbors = [furtherWithDirection(direc: .up)]
            case .downSlope:
                potentialNeighbors = [furtherWithDirection(direc: .down)]
            default:
                potentialNeighbors = allDirections.map { furtherWithDirection(direc: $0) }
            }
        }

        return potentialNeighbors.filter {
            ($0.row >= 0 && $0.col >= 0 && $0.row < height && $0.col < width)
            && lines[$0.row][$0.col] != .tree
        }
    }
}

struct Junction {
    let coord: Coord
    var neighbors: [(Coord, Int)]
    var level: Int?
    
    var onPerimeter: Bool {
        return neighbors.count <= 3
    }
}

let lines = contents.split(whereSeparator: \.isNewline).map { $0.map { Spot(rawValue: String($0))!} }

let height = lines.count
let width = lines[0].count

let allDirections: Set<Direction> = [.left, .right, .up, .down]

// start point is the ONLY open spot in the first row
let startCol = lines[0].firstIndex { $0 == .path }!
let starter = Coord(row: 0, col: startCol)

let endCol = lines.last!.firstIndex { $0 == .path }!
let laster = Coord(row: height - 1, col: endCol)

func printSurrounding(_ coord: Coord) {
    for row in (coord.row - 1)...(coord.row + 1) {
        var line = ""
        for col in (coord.col - 1)...(coord.col + 1) {
            line += lines[row][col].rawValue
        }
        print(line)
    }
}

// looking for next coord with multiple neighbors
// returns found coord and dist
func findNextJunctionCoord(lead: Coord, start: Coord) -> (Coord, Int)? {
    var dist = 1
    var last: Coord = start
    var curr: Coord = lead
    var curr_neighbors = curr.getValidNeighbors()
    while curr_neighbors.count < 3 {
        // if we end up at the start/end coord, return. basically an end of edge
        if curr == laster || curr == starter {
            return (curr, dist)
        }
        // return if no path exists
        guard let next = curr_neighbors.filter({ $0 != last }).first else {
            return nil
        }
        last = curr
        curr = next
        curr_neighbors = curr.getValidNeighbors()
        dist += 1
    }

    return (curr, dist)
}

func adjuncicate() -> Int {
    var junctionCoords: Set<Coord> = [starter, laster]
    // identify all junctions
    for row in 0..<height {
        for col in 0..<width {
            if Coord(row: row, col: col).isJunction {
                junctionCoords.insert(Coord(row: row, col: col))
            }
        }
    }

    var junctions: [Coord: Junction] = [:]
    // find all junction neighbors
    for coord in junctionCoords {
        let neighbors: [(Coord, Int)] = coord.getValidNeighbors().reduce(into: []) { result, next in
            if let nextJuncCoord = findNextJunctionCoord(lead: next, start: coord) {
                result.append(nextJuncCoord)
            }
        }
        junctions[coord] = Junction(coord: coord, neighbors: neighbors)
    }
    
    var seenLevels: Set<Coord> = [starter]
    var lastLevel: Set<Coord> = [starter]
    junctions[starter]!.level = 0

    var level = 1
    // identify all junction "levels" (# of nodes from start)
    // used to help cut off impossible back tracking
    while seenLevels.count < junctionCoords.count {
        let next = Set(lastLevel.flatMap { junctions[$0]!.neighbors.map { $0.0 }}).filter { !seenLevels.contains($0) }
        for juncCoord in next {
            guard var junc = junctions[juncCoord] else {
                print("Somehow a junction disappeared")
                exit(1)
            }
            junc.level = level
            // if a perimeter tile, don't allow backtracing to a perimeter with a level lower than itself, it's inescapable
            if junc.onPerimeter {
                junc.neighbors = junc.neighbors.filter {
                    let doubleNeighbor = junctions[$0.0]!
                    if let doubleLevel = doubleNeighbor.level {
                        if doubleNeighbor.onPerimeter && doubleLevel < junc.level! {
                            return false
                        }
                    }
                    return true
                }
            }
            junctions[juncCoord] = junc
        }
        seenLevels.formUnion(next)
        lastLevel = next
        level += 1
    }
    
    // okay now just try them all
    var lineage: Set<Coord> = [starter]
    let worst = searchForJunctionWalk(starter, dist: 0, lineage: &lineage, junctions: junctions)
    
    return worst
}

func searchForJunctionWalk(_ curr: Coord, dist: Int, lineage: inout Set<Coord>, junctions: [Coord: Junction]) -> Int {
    // if we hit the end col, not much more to do. just need to see if we can get there any slower
    guard curr != laster else {
        return dist
    }
    // should always been initialized
    guard let junc = junctions[curr] else {
        print("Junction \(curr) doesn't exist. Exiting")
        exit(1)
    }
    var worst_distance = 0
    let neighbors = junc.neighbors.filter { !lineage.contains($0.0) }
    for neighbor in neighbors {
        lineage.insert(neighbor.0)
        let neighbor_longest = searchForJunctionWalk(neighbor.0, dist: dist + neighbor.1, lineage: &lineage, junctions: junctions)
        lineage.remove(neighbor.0)
        worst_distance = max(worst_distance, neighbor_longest)
    }
    
    return worst_distance
}


// PART_TWO handled within
let clock = ContinuousClock()
let elapsed = clock.measure {
    let result = adjuncicate()
    print("Longest Walk: \(result)")
}
print("Took \(elapsed.formatted())")
