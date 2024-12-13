//
//  main.swift
//  Day 12
//
//  Created by Lucas Kellar on 12/12/24.
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

let lines = contents.split(whereSeparator: \.isNewline).map { Array($0) }

let height = lines.count
let width = lines[0].count

var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: width), count: height)

enum Direction {
    case Right
    case Left
    case Up
    case Down
}

let DIRECTIONS_LIST: [Direction] = [.Right, .Down, .Up, .Left]

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
    
    func furtherWithDirection(direcs: [Direction]) -> Coord {
        var next = self
        for direc in direcs {
            next = next.furtherWithDirection(direc: direc)
        }
        return next
    }
    
    // returns all inbound directions
    func allDirections() -> [Coord] {
        return DIRECTIONS_LIST.map { furtherWithDirection(direc: $0) }
    }
    
    // generate all 2x2 matrices with this coord in them
    func generateCoordtets() -> [[[Coord]]] {
        return [
            [
                [furtherWithDirection(direcs: [.Up, .Left]), furtherWithDirection(direc: .Up)],
                [furtherWithDirection(direc: .Left), self]
            ],
            [
                [furtherWithDirection(direc: .Up), furtherWithDirection(direcs: [.Up, .Right])],
                [self, furtherWithDirection(direc: .Right)]
            ],
            [
                [self, furtherWithDirection(direc: .Right)],
                [furtherWithDirection(direc: .Down), furtherWithDirection(direcs: [.Down, .Right])]
            ],
            [
                [furtherWithDirection(direc: .Left), self],
                [furtherWithDirection(direcs: [.Left, .Down]), furtherWithDirection(direc: .Down)]
            ]
        ]
    }
}

func inBounds(_ coord: Coord) -> Bool {
    return 0 <= coord.x && coord.x < width && 0 <= coord.y && coord.y < height
}

func getPoint(_ coord: Coord) -> Character? {
    // return nil if out of bounds
    guard inBounds(coord) else {
        return nil
    }
    
    return lines[coord.y][coord.x]
}

// accepts a 2x2 coord matrix and a target coord. returns if that coord is a corner
func isCorner(coordtet: [[Coord]], target: Coord) -> Bool {
    let target_y = coordtet[0].contains(target) ? 0 : 1
    guard let target_x = coordtet[target_y].firstIndex(of: target) else {
        print("Target \(target) not found in coordtet: \(coordtet)")
        exit(1)
    }
    
    let target_char = getPoint(target)
    let across_internal = Coord((target_x + 1) % 2, (target_y + 1) % 2)
    let across = getPoint(coordtet[across_internal.y][across_internal.x])
    let nextTo = [Coord((target_x + 1) % 2, target_y), Coord(target_x, (target_y + 1) % 2)]
        .map { coordtet[$0.y][$0.x] }
        .map { getPoint($0) }
    
    // Case 1: target is unique
    if across != target_char && !nextTo.contains(target_char) {
        return true
    }
    // Case 2: nextTos are target and across is not target
    if across != target_char && nextTo.allSatisfy({ $0 == target_char }) {
        return true
    }
    // Case 3: across is target and both across are not
    if across == target_char && !nextTo.contains(target_char) {
        return true
    }
    return false
}

struct Region {
    let char: Character
    let area: Int
    let perimeter: Int
    let sides: Int
    
    init(char: Character, points: Set<Coord>) {
        self.char = char
        area = points.count
        perimeter = points.reduce(into: 0) { result, point in
            result += point.allDirections().count { !points.contains($0) }
        }
        // theory is that # of corners = # of sides
        sides = points.reduce(into: 0) { result, point in
            result += point.generateCoordtets().count { isCorner(coordtet: $0, target: point) }
        }
    }
}

func buildRegion(coord: Coord) -> Region? {
    guard !visited[coord.y][coord.x] else {
        return nil
    }
    
    let char = lines[coord.y][coord.x]
    
    var stack: [Coord] = [coord]
    var points = Set<Coord>()
    
    while let next = stack.popLast() {
        points.insert(next)
        visited[next.y][next.x] = true
        stack.append(contentsOf: next.allDirections().filter {
            inBounds($0) && visited[$0.y][$0.x] == false && lines[$0.y][$0.x] == char
        })
    }
    
    return Region(char: char, points: points)
}

func compute() {
    var regions: [Region] = []

    for y in 0..<height {
        for x in 0..<width {
            if let region = buildRegion(coord: Coord(x, y)) {
                regions.append(region)
            }
        }
    }
    
    var total = 0
    for region in regions {
        total += region.area * region.perimeter
    }
    
    print("Part One Fence Cost: \(total)")
    
    total = 0
    for region in regions {
        total += region.area * region.sides
    }
    
    print("Part Two Fence Cost: \(total)")
}

compute()

