//
//  main.swift
//  Day 23
//
//  Created by Lucas Kellar on 7/19/25.
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
let height = lines.count
let width = lines[0].count

enum Spot: Character {
    case Elf = "#"
    case Empty = "."
}

enum Direction: Int {
    case North = 0
    case South = 1
    case West = 2
    case East = 3
    
    var next: Direction {
        if self == .East {
            return .North
        }
        return Direction(rawValue: self.rawValue + 1)!
    }
}

var elves: [Elf] = []
// should be rebuild before each proposal round
var currentPositions: Set<Coord> = []
// coord and how many are proposing to move there, should be rebuilt after proposal before matching
var proposals: [Coord: Int] = [:]

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
        case .East:
            return Coord(x + 1, y)
        case .West:
            return Coord(x - 1, y)
        case .North:
            return Coord(x, y - 1)
        case .South:
            return Coord(x, y + 1)
        }
    }
    
    // returns adjacent on a side (e.g. north returns the NW, N, and NE coords)
    func returnAdjacent(direc: Direction) -> [Coord] {
        switch direc {
        case .North:
            let base = furtherWithDirection(direc: .North)
            return [base.furtherWithDirection(direc: .West), base, base.furtherWithDirection(direc: .East)]
        case .West:
            let base = furtherWithDirection(direc: .West)
            return [base.furtherWithDirection(direc: .South), base, base.furtherWithDirection(direc: .North)]
        case .South:
            let base = furtherWithDirection(direc: .South)
            return [base.furtherWithDirection(direc: .East), base, base.furtherWithDirection(direc: .West)]
        case .East:
            let base = furtherWithDirection(direc: .East)
            return [base.furtherWithDirection(direc: .North), base, base.furtherWithDirection(direc: .South)]
        }
    }
}

struct Elf {
    let position: Coord
    let proposedPosition: Coord?
    let nextDirection: Direction
    
    init(position: Coord, proposedPosition: Coord?, nextDirection: Direction) {
        self.position = position
        self.proposedPosition = proposedPosition
        self.nextDirection = nextDirection
    }
    
    func propose() -> Elf {
        // try up to all directions
        var proposedDirections: [Direction] = [self.nextDirection]
        for _ in 0..<3 {
            proposedDirections.append(proposedDirections.last!.next)
        }
        let adjacents = proposedDirections.map { position.returnAdjacent(direc: $0) }
        // if there are no neighboring elves, no need to move
        guard !adjacents.joined().allSatisfy({ !currentPositions.contains($0) }) else {
            return Elf(position: self.position, proposedPosition: nil, nextDirection: self.nextDirection.next)
        }
        
        for index in 0..<4 {
            if adjacents[index].allSatisfy({ !currentPositions.contains($0) }) {
                // the middle adjacent is ALWAYS the "One Direction Away" (e.g. NW, N, NE)
                return Elf(position: self.position, proposedPosition: adjacents[index][1], nextDirection: self.nextDirection.next)
            }
        }
        return Elf(position: self.position, proposedPosition: nil, nextDirection: self.nextDirection.next)
    }
    
    func match() -> Elf {
        guard let proposedPosition = proposedPosition else {
            return self
        }
        guard let count = proposals[proposedPosition] else {
            print("Can't find \(proposedPosition) in proposals")
            exit(1)
        }
        guard count == 1 else {
            return Elf(position: self.position, proposedPosition: nil, nextDirection: self.nextDirection)
        }
        
        return Elf(position: proposedPosition, proposedPosition: nil, nextDirection: self.nextDirection)
    }
}

var y = 0
for line in lines {
    var x = 0
    for char in line {
        let spot = Spot(rawValue: char)!
        if spot == .Elf {
            elves.append(Elf(position: Coord(x, y), proposedPosition: nil, nextDirection: .North))
        }
        x += 1
    }
    y += 1
}

func isMoreExtreme(existing: Elf, candidate: Elf, direction: Direction) -> Bool {
    switch direction {
    case .East:
        return candidate.position.x > existing.position.x
    case .West:
        return candidate.position.x < existing.position.x
    case .North:
        return candidate.position.y < existing.position.y
    case .South:
        return candidate.position.y > existing.position.y
    }
}

// returns top left and bottom right
func computeCorners() -> (Coord, Coord) {
    var extremes: [Elf] = Array(repeating: elves[0], count: 4)
    for elf in elves[1...] {
        for index in 0..<4 {
            let direction = Direction(rawValue: index)!
            if isMoreExtreme(existing: extremes[index], candidate: elf, direction: direction) {
                extremes[index] = elf
            }
        }
    }
    return (Coord(extremes[Direction.West.rawValue].position.x, extremes[Direction.North.rawValue].position.y), Coord(extremes[Direction.East.rawValue].position.x, extremes[Direction.South.rawValue].position.y))
}

func computeEmptyGround() -> Int {
    let corners = computeCorners()
    let recWidth = (corners.1.x - corners.0.x) + 1
    let recHeight = (corners.1.y - corners.0.y) + 1
    return (recWidth * recHeight) - elves.count
}

// assumes positions are updated
func printMap() {
    let corners = computeCorners()
    for y in corners.0.y...corners.1.y {
        var line = ""
        for x in corners.0.x...corners.1.x {
            let coord = Coord(x, y)
            if currentPositions.contains(coord) {
                line += "#"
            } else {
                line += "."
            }
        }
        print(line)
    }
}

func compute() -> Int {
    // ten rounds
    currentPositions = Set(elves.map { $0.position })
    var roundNo = 0
    repeat {
        if !PART_TWO && roundNo == 10 {
            return computeEmptyGround()
        }
        
        elves = elves.map { $0.propose() }
        proposals = elves.reduce(into: [:]) { result, next in
            guard let proposedPosition = next.proposedPosition else {
                return
            }
            if let value = result[proposedPosition] {
                result[proposedPosition] = value + 1
            } else {
                result[proposedPosition] = 1
            }
        }
        elves = elves.map { $0.match() }
        currentPositions = Set(elves.map { $0.position })
        roundNo += 1
    } while !proposals.isEmpty
    if PART_TWO {
        return roundNo
    } else {
        return computeEmptyGround()
    }
}

if PART_TWO {
    print("Round when the moving stops: \(compute())")
} else {
    print("Empty space after Round 10 / Stop Moving: \(compute())")
}
