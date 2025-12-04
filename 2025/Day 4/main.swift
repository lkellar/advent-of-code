//
//  main.swift
//  Day 4
//
//  Created by Lucas Kellar on 12/4/25.
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

enum Spot: Character {
    case empty = "."
    case paper = "@"
}

// split into 2d array of chars
var lines = contents.split(whereSeparator: \.isNewline).map { Array($0).map { Spot(rawValue: $0)!} }

let height = lines.count
let width = lines[0].count

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let allDirections: [Direction] = [.Right, .Left, .Up, .Down]
let opposites: [Direction: Direction] = [.Right : .Left, .Up: .Down, .Down: .Up, .Left: .Right]

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    func furtherWithDirection(direc: Direction) -> Coord {
        switch direc {
        case .Right:
            return Coord(x + 1, y)
        case .Left:
            return Coord(x - 1, y)
        case .Up:
            return Coord(x, y - 1)
        case .Down:
            return Coord(x, y + 1)
        }
    }
    
    var inBounds: Bool {
        if self.x < 0 || self.x >= width {
            return false
        }
        if self.y < 0 || self.y >= height {
            return false
        }
        return true
    }
    
    // gets N, NE, E, SE, S, SW, W, NE
    func furtherWithAllEightDirections() -> [Coord] {
        var results: Set<Coord> = []
        for outerDir in allDirections {
            let partial = self.furtherWithDirection(direc: outerDir)
            results.insert(partial)
            for innerDir in allDirections {
                if outerDir == innerDir || opposites[innerDir] == outerDir {
                    continue
                }
                results.insert(partial.furtherWithDirection(direc: innerDir))
            }
        }
        assert(results.count == 8)
        return Array(results)
    }
}

func getSpot(_ coord: Coord) -> Spot {
    return lines[coord.y][coord.x]
}

func printMap(markers: Set<Coord>) {
    for y in 0..<height {
        var row = ""
        for x in 0..<width {
            let coord = Coord(x, y)
            if markers.contains(coord) {
                row += "x"
            } else {
                let spot = getSpot(coord)
                row += String(spot.rawValue)
            }
        }
        print(row)
    }
}

func fetchEligibleSpots() -> Set<Coord> {
    var eligibleSpots = Set<Coord>()
    for y in 0..<height {
        for x in 0..<width {
            let coord = Coord(x,y)
            guard getSpot(coord) == .paper else {
                continue
            }
            let neighbors = coord
                .furtherWithAllEightDirections()
                .filter { $0.inBounds }
            
            let neighboringPaperCount = neighbors.count {
                getSpot($0) == .paper
            }
            if neighboringPaperCount < 4 {
                eligibleSpots.insert(coord)
            }
        }
    }
    return eligibleSpots
}

func deletePaperRolls(spots: Set<Coord>) {
    for coord in spots {
        assert(getSpot(coord) == .paper)
        lines[coord.y][coord.x] = .empty
    }
}

func partOne() {
    let eligibleSpots = fetchEligibleSpots()
    print("Total Available Paper Rolls: \(eligibleSpots.count)")
}

func partTwo() {
    var eligibleSpots = fetchEligibleSpots()
    var total = 0
    while eligibleSpots.count > 0 {
        deletePaperRolls(spots: eligibleSpots)
        total += eligibleSpots.count
        
        eligibleSpots = fetchEligibleSpots()
    }
    
    print("Total Removable Rolls: \(total)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
