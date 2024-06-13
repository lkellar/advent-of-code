//
//  main.swift
//  Day 17
//
//  Created by Lucas Kellar on 12/27/23.
//

import Foundation

let path = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let MIN_STRAIGHT_LINE = PART_TWO ? 4 : 0
let MAX_STRAIGHT_LINE = PART_TWO ? 10 : 3

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let lines = contents.split(whereSeparator: \.isNewline).map { $0.map {Int(String($0))!} }
let height = lines.count
let width = lines[0].count

struct Primum {
    var visited: Bool = false
    var best_distance: Int = Int.max
    var parent: Coord? = nil
}

// row col stra dire
var prims = Array(repeating: Array(repeating: Array(repeating: Array(repeating: Primum(), count: 5), count: MAX_STRAIGHT_LINE), count: width), count: height)

enum Direction: Int {
    case Right = 0
    case Left = 1
    case Up = 2
    case Down = 3
    case None = 4
}

let directionFlips: [Direction: Direction] = [.Right: .Left, .Left: .Right, .Up: .Down, .Down: .Up, .None: .None]
let allDirections: Set<Direction> = [.Left, .Right, .Up, .Down]

struct Coord: Hashable {
    let row: Int;
    let col: Int;
    // how many times it's been going in a straight line at this point
    let straight: Int;
    let dir: Direction
    
    func furtherWithDirection(direc: Direction) -> Coord {
        let straig = direc == dir ? straight + 1 : 0
        switch direc {
        case .Right:
            return Coord(row: row, col: col + 1, straight: straig, dir: direc)
        case .Left:
            return Coord(row: row, col: col - 1, straight: straig, dir: direc)
        case .Up:
            return Coord(row: row - 1, col: col, straight: straig, dir: direc)
        case .Down:
            return Coord(row: row + 1, col: col, straight: straig, dir: direc)
        case .None:
            print("Can't further in the none direction")
            exit(1)
        }
    }
    
    func getNeighbors() -> [Coord] {
        return allDirections.subtracting([directionFlips[dir]!]).map { furtherWithDirection(direc: $0) }
    }
    
    func getDirectionless() -> Coord {
        return Coord(row: row, col: col, straight: straight, dir: .None)
    }
}

// assumes they're only one spot apart
func determineDirection(row: Int, col: Int, parent: Coord) -> Direction {
    if parent.row != row {
        if row > parent.row {
            return .Down
        } else {
            return .Up
        }
    } else {
        if col > parent.col {
            return .Right
        } else {
            return .Left
        }
    }
}

func findClosestUnvisited() -> Coord {
    var closest: Coord? = nil
    var best_distance = Int.max
    for (row_i, row) in prims.enumerated() {
        for (col_i, col) in row.enumerated() {
            for (stra_i, stra) in col.enumerated() {
                for (dir_i, dir) in stra.enumerated() {
                    if !dir.visited && dir.best_distance < best_distance {
                        closest = Coord(row: row_i, col: col_i, straight: stra_i, dir: Direction(rawValue: dir_i) ?? .None)
                        best_distance = dir.best_distance
                    }
                }
            }
        }
    }
    if (best_distance == Int.max) {
        exit(1)
    }
    return closest!
}

// FILL WITH ALL UNVISITED
var unvisited = Set<Coord>()

func popClosestProbableUnvisited() -> Coord? {
    var closest: Coord? = nil
    var best_distance = Int.max
    for coord in unvisited {
        let stra = prims[coord.row][coord.col][coord.straight][coord.dir.rawValue]
        if stra.visited {
            unvisited.remove(coord)
            continue;
        }
        if !stra.visited && stra.best_distance < best_distance {
            closest = coord
            best_distance = stra.best_distance
        }
    }
    if let closest = closest {
        unvisited.remove(closest)
    }
    return closest
}

func workBackPath(coord: Coord) -> [Coord] {
    var curr = coord
    var listo = [coord]
    var total = lines[curr.row][curr.col]
    while let parent = prims[curr.row][curr.col][curr.straight][curr.dir.rawValue].parent {
        curr = parent
        total += lines[curr.row][curr.col]
        listo.append(curr)
    }
    return listo
}

let directionArrows: [Direction: String] = [.Right: ">", .Left: "<", .Up: "^", .Down: "v", .None: "."];

func printMapWithPath(path: [Coord]) {
    var linesTwo = lines.map {$0.map {String($0)}};
    for coord in path {
        linesTwo[coord.row][coord.col] = directionArrows[coord.dir] ?? ".";
    }
    
    print("Map:")
    for line in linesTwo {
        print(line.joined(separator: ""))
    }
    print()
}

func findShortestDistance() -> Int {
    var curr = Coord(row: 0, col: 0, straight: 0, dir: .None)
    prims[curr.row][curr.col][curr.straight][curr.dir.rawValue].best_distance = 0
    var iterations = 0;
    while true{
        prims[curr.row][curr.col][curr.straight][curr.dir.rawValue].visited = true
        if curr.row == height - 1 && curr.col == width - 1 && (!PART_TWO || curr.straight >= (MIN_STRAIGHT_LINE - 1)) {
            let path = workBackPath(coord: curr)
            printMapWithPath(path: path)
            return path.dropLast().reduce(0, {result, coord in
                return result + lines[coord.row][coord.col]
            })
        }
        let neighbors = curr.getNeighbors().filter {
            $0.straight < MAX_STRAIGHT_LINE
            && (curr.dir == .None || $0.straight > 0 || ($0.straight == 0 && curr.straight >= (MIN_STRAIGHT_LINE - 1)))
            && $0.row >= 0 && $0.col >= 0 && $0.row < height && $0.col < width
            && prims[$0.row][$0.col][$0.straight][$0.dir.rawValue].visited == false
        }
        
        for neighbor in neighbors {
            unvisited.insert(neighbor)
            let tenative_distance = prims[curr.row][curr.col][curr.straight][curr.dir.rawValue].best_distance + lines[neighbor.row][neighbor.col]
            if tenative_distance < prims[neighbor.row][neighbor.col][neighbor.straight][neighbor.dir.rawValue].best_distance {
                prims[neighbor.row][neighbor.col][neighbor.straight][neighbor.dir.rawValue].best_distance = tenative_distance
                prims[neighbor.row][neighbor.col][neighbor.straight][neighbor.dir.rawValue].parent = curr
            }
        }
        
        curr = popClosestProbableUnvisited() ?? findClosestUnvisited();
        iterations += 1;
    }
}

print("Total: \(findShortestDistance())")

