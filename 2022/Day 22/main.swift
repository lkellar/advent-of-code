//
//  main.swift
//  Day 22
//
//  Created by Lucas Kellar on 7/7/25.
//

import Foundation

let path = CommandLine.arguments[1]
let EDGE_LENGTH = Int(CommandLine.arguments[2])!

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
    case Empty = " "
    case Occupied = "#"
    case Free = "."
}

let lines: [String] = contents.split(whereSeparator: \.isNewline).map { String($0) }

enum Direction: Int {
    case Right = 0
    case Down = 1
    case Left = 2
    case Up = 3
}

let height = lines.count - 1

let spots: [[Spot]] = lines[0..<height].map { $0.map { char in Spot(rawValue: char)! } }

let allDirections: [Direction] = [.Right, .Down, .Up, .Left]

let turning: [Direction: [Character: Direction]] = [
    .Right: ["L": .Up, "R": .Down],
    .Down: ["L": .Right, "R": .Left],
    .Left: ["L": .Down, "R": .Up],
    .Up: ["L": .Left, "R": .Right]
]

var portals: [Portal] = []

// grid is where 0,0 is top left
struct Coord: Hashable {
    let x: Int
    let y: Int
    let dir: Direction
    
    // neutral direction for visited purposes
    var neutral: Coord {
        return Coord(forceX: self.x, forceY: self.y, forceDir: .Up)
    }
    
    init(_ x: Int, _ y: Int, _ dir: Direction) {
        if PART_TWO {
            for portal in portals {
                if let coord = portal.tryPortal(x, y, dir) {
                    self = coord
                    return
                }
            }
            guard y < height else {
                printMap()
                print("Invalid Coord: (\(x), \(y), \(dir))")
                exit(1)
            }
            let width = lines[y].count
            guard x < width else {
                printMap()
                print("Invalid Coord: (\(x), \(y), \(dir))")
                exit(1)
            }
            self.x = x
            self.y = y
            self.dir = dir
        } else {
            self.dir = dir
            if y == -1 {
                self.y = height - 1
            } else {
                self.y = y % height
            }
            let width = lines[self.y].count
            if x == -1 {
                self.x = width - 1
            } else {
                self.x = x % width
            }
        }
    }
    
    init(forceX: Int, forceY: Int, forceDir: Direction) {
        self.x = forceX
        self.y = forceY
        self.dir = forceDir
    }
    
    func furtherWithDirection() -> Coord {
        switch self.dir {
        case .Right:
            return Coord(x + 1, y, self.dir)
        case .Left:
            return Coord(x - 1, y, self.dir)
        case .Up:
            return Coord(x, y - 1, self.dir)
        case .Down:
            return Coord(x, y + 1, self.dir)
        }
    }
}

struct Portal {
    let inputXRange: ClosedRange<Int>
    let inputYRange: ClosedRange<Int>
    let inputDir: Direction
    
    let transform: (Int, Int) -> Coord
    
    func tryPortal(_ x: Int, _ y: Int, _ dir: Direction) -> Coord? {
        guard inputXRange.contains(x) && inputYRange.contains(y) && dir == inputDir else {
            return nil
        }
        
        return transform(x, y)
    }
}

// All p2 nets are the same, so hardcoding the portals
portals = [
    // Red
    Portal(inputXRange: 50...99, inputYRange: (-1)...(-1), inputDir: .Up, transform: {x, y in Coord(forceX: 0, forceY: x + 100, forceDir: .Right) }),
    Portal(inputXRange: (-1)...(-1), inputYRange: 150...199, inputDir: .Left, transform: {x, y in Coord(forceX: y - 100, forceY: 0, forceDir: .Down) }),
    // Blue
    Portal(inputXRange: 100...149, inputYRange: (-1)...(-1), inputDir: .Up, transform: {x, y in Coord(forceX: x - 100, forceY: 199, forceDir: .Up)}),
    Portal(inputXRange: 0...49, inputYRange: 200...200, inputDir: .Down, transform: {x, y in Coord(forceX: x + 100, forceY: 0, forceDir: .Down)}),
    // Purple
    Portal(inputXRange: 49...49, inputYRange: 0...49, inputDir: .Left, transform: {x, y in Coord(forceX: 0, forceY: 149 - y, forceDir: .Right)}),
    Portal(inputXRange: (-1)...(-1), inputYRange: 100...149, inputDir: .Left, transform: {x, y in Coord(forceX: 50, forceY: 149 - y, forceDir: .Right)}),
    // Green
    Portal(inputXRange: 150...150, inputYRange: 0...49, inputDir: .Right, transform: {x, y in Coord(forceX: 99, forceY: 149 - y, forceDir: .Left)}),
    Portal(inputXRange: 100...100, inputYRange: 100...149, inputDir: .Right, transform: {x, y in Coord(forceX: 149, forceY: 149 - y, forceDir: .Left)}),
    // Left Arc
    Portal(inputXRange: 49...49, inputYRange: 50...99, inputDir: .Left, transform: {x, y in Coord(forceX: y - 50, forceY: 100, forceDir: .Down)}),
    Portal(inputXRange: 0...49, inputYRange: 99...99, inputDir: .Up, transform: {x, y in Coord(forceX: 50, forceY: x + 50, forceDir: .Right)}),
    // Right Arc
    Portal(inputXRange: 100...149, inputYRange: 50...50, inputDir: .Down, transform: {x, y in Coord(forceX: 99, forceY: x - 50, forceDir: .Left)}),
    Portal(inputXRange: 100...100, inputYRange: 50...99, inputDir: .Right, transform: {x, y in Coord(forceX: y + 50, forceY: 49, forceDir: .Up)}),
    // Bottom Arc
    Portal(inputXRange: 50...99, inputYRange: 150...150, inputDir: .Down, transform: {x, y in Coord(forceX: 49, forceY: x + 100, forceDir: .Left)}),
    Portal(inputXRange: 50...50, inputYRange: 150...199, inputDir: .Right, transform: {x, y in Coord(forceX: y - 100, forceY: 149, forceDir: .Up)})
]

struct Side {
    let topLeft: Coord
    let yRange: ClosedRange<Int>
    let xRange: ClosedRange<Int>
    
    init(topLeft: Coord) {
        self.topLeft = topLeft
        self.yRange = (topLeft.y)...(topLeft.y + EDGE_LENGTH)
        self.xRange = (topLeft.x)...(topLeft.x + EDGE_LENGTH)
    }
    
    func contains(_ coord: Coord) -> Bool {
        return self.xRange.contains(coord.x) && self.yRange.contains(coord.y)
    }
}

let commandLine = lines.last!

let NUMBER_REGEX = /[0-9]+/

var visited: Set<Coord> = []

func computeStopPoint(instructionString: String) -> Int? {
    var instructions = instructionString
    let startingX: Int = spots[0].distance(from: spots[0].startIndex, to: spots[0].firstIndex(of: .Free)!)
    var coord = Coord(startingX, 0, .Right)
    visited.insert(coord)
    while let match = instructions.prefixMatch(of: NUMBER_REGEX) {
        let distanceStr = match.output
        let distance = Int(distanceStr)!
        instructions.removeFirst(distanceStr.count)
        for _ in 0..<distance {
            let lastCoord: Coord = coord
            if PART_TWO {
                coord = coord.furtherWithDirection()
                if spots[coord.y][coord.x] == .Empty {
                    print("Ended up at an invalid spot: (\(coord.x), \(coord.y), \(coord.dir))")
                    exit(1)
                }
            } else {
                repeat {
                    coord = coord.furtherWithDirection()
                } while spots[coord.y][coord.x] == .Empty
            }
            if spots[coord.y][coord.x] == .Occupied {
                coord = lastCoord
                break
            }
            visited.insert(coord.neutral)
        }
        if !instructions.isEmpty {
            let dirChar = instructions.removeFirst()
            let facing = turning[coord.dir]![dirChar]!
            coord = Coord(forceX: coord.x, forceY: coord.y, forceDir: facing)
        }
    }
    return 1000 * (coord.y + 1) + 4 * (coord.x + 1) + coord.dir.rawValue
}

func printMap(markers: Set<Coord> = visited) {
    for y in (-1)...height {
        var line = ""
        for x in (-1)...151 {
            let coord = Coord(forceX: x, forceY: y, forceDir: .Up)
            if markers.contains(coord) {
                line += "@"
            } else if (0..<height).contains(y) && (0..<spots[y].count).contains(x) {
                line += String(spots[y][x].rawValue)
            } else {
                line += " "
            }
        }
        print(line)
    }
}

print("Monkey Password: \(computeStopPoint(instructionString: lines.last!) ?? -1)")
