//
//  main.swift
//  Day 18
//
//  Created by Lucas Kellar on 7/2/25.
//

import Foundation

let filepath = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: filepath, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let COORD_REGEX = /([0-9]+),([0-9]+),([0-9]+)/

enum Direction {
    case Right
    case Left
    case Up
    case Down
    case Back
    case Front
}

let allDirections: [Direction] = [.Right, .Down, .Up, .Left, .Back, .Front]
struct Coord: Hashable {
    let x: Int
    let y: Int
    let z: Int
    
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    
    var inBounds: Bool {
        return 0 <= x && x <= largestX && 0 <= y && y <= largestY && 0 <= z && z <= largestZ
    }
    
    func furtherWithDirection(direc: Direction) -> Coord {
        switch direc {
        case .Right:
            return Coord(x + 1, y, z)
        case .Left:
            return Coord(x - 1, y, z)
        case .Up:
            return Coord(x, y - 1, z)
        case .Down:
            return Coord(x, y + 1, z)
        case .Back:
            return Coord(x, y, z - 1)
        case .Front:
            return Coord(x, y, z + 1)
        }
    }
    
    // returns all inbound directions
    func allValidDirections() -> [Coord] {
        return allDirections.map { furtherWithDirection(direc: $0) }
    }
}

enum Space {
    case occupied
    // accessible to outside
    case accessible
    case unaccessible
    // default if not known
    case unknown
}

var largestX = 0
var largestY = 0
var largestZ = 0

var coords: [Coord] = []

for line in lines {
    guard let match = line.wholeMatch(of: COORD_REGEX) else {
        print("No match")
        exit(1)
    }
    let coord = Coord(Int(match.output.1)!, Int(match.output.2)!, Int(match.output.3)!)
    coords.append(coord)
    
    largestX = max(coord.x, largestX)
    largestY = max(coord.y, largestY)
    largestZ = max(coord.z, largestZ)
}

var map: [[[Space]]] = Array(repeating: Array(repeating: Array(repeating: .unknown, count: largestZ + 1), count: largestX + 1), count: largestY + 1)

for coord in coords {
    map[coord.y][coord.x][coord.z] = .occupied
}

func compute(targetSpace: Space) -> Int {
    var total = 0
    for coord in coords {
        total += coord.allValidDirections().count {
            !$0.inBounds || map[$0.y][$0.x][$0.z] == targetSpace
        }
    }
    return total
}

func partTwo() -> Int {
    for y in 0...largestY {
        for x in 0...largestX {
            for z in 0...largestZ {
                let currentCoord: Coord = Coord(x, y, z)
                guard map[currentCoord.y][currentCoord.x][currentCoord.z] == .unknown else {
                    continue
                }
                var queue: [Coord] = [currentCoord]
                var seen: Set<Coord> = []
                var found = false
                while let next = queue.popLast() {
                    let spot = map[next.y][next.x][next.z]
                    if spot == .accessible || spot == .unaccessible {
                        for coord in seen {
                            map[coord.y][coord.x][coord.z] = spot
                        }
                        found = true
                        break
                    }
                    seen.insert(next)
                    
                    let neighbors = next.allValidDirections()
                    if (neighbors.contains { !$0.inBounds }) {
                        for coord in seen {
                            map[coord.y][coord.x][coord.z] = .accessible
                        }
                        found = true
                        break
                    }
                    queue.append(contentsOf: neighbors.filter { !seen.contains($0) && map[$0.y][$0.x][$0.z] != .occupied })
                }
                if !found {
                    for coord in seen {
                        map[coord.y][coord.x][coord.z] = .unaccessible
                    }
                }
            }
        }
    }
    
    return compute(targetSpace: .accessible)
}

if PART_TWO {
    print("Exterior Surface Area: \(partTwo())")
} else {
    print("Surface Area: \(compute(targetSpace: .unknown))")
}
