//
//  main.swift
//  Day 10
//
//  Created by Lucas Kellar on 12/11/23.
//
// i am aware this is horribly organized but it works :)

import Foundation

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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

enum Pipe: Character {
    case Vertical = "|"
    case Horizontal = "-"
    case NorthEast = "L"
    case NorthWest = "J"
    case SouthEast = "F"
    case SouthWest = "7"
    case Ground = "."
    case Start = "S"
}

struct Coord: Equatable, Hashable {
    let x: Int;
    let y: Int;
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

var start_perhaps: Coord?;
let map = lines.enumerated().map {y, row in
    row.enumerated().map {x, col in
        let pipe = Pipe(rawValue: col)!
        if pipe == Pipe.Start {
            start_perhaps = Coord(x, y);
        }
        return pipe
    }
}

// quick and unsafe nil checking lol
let start = start_perhaps!

func getNextPipe(current: Coord, prev: Coord) -> Coord {
    let pipe = map[current.y][current.x]
    switch pipe {
    case Pipe.Vertical:
        if prev.y < current.y {
            return Coord(current.x, current.y + 1)
        }
        return Coord(current.x, current.y - 1)
    case Pipe.Horizontal:
        if prev.x < current.x {
            return Coord(current.x + 1, current.y)
        }
        return Coord(current.x - 1, current.y)
    case Pipe.NorthEast:
        if prev.y < current.y {
            return Coord(current.x + 1, current.y)
        }
        return Coord(current.x, current.y - 1)
    case Pipe.NorthWest:
        if prev.y < current.y {
            return Coord(current.x - 1, current.y)
        }
        return Coord(current.x, current.y - 1)
    case Pipe.SouthEast:
        if prev.y > current.y {
            return Coord(current.x + 1, current.y)
        }
        return Coord(current.x, current.y + 1)
    case Pipe.SouthWest:
        if prev.y > current.y {
            return Coord(current.x - 1, current.y)
        }
        return Coord(current.x, current.y + 1)
    default:
        fatalError("No we aren't doing \(pipe) here")
    }
}

func findConnectingPipes(current: Coord) -> [Coord] {
    var coords = [Coord]()
    if current.x != 0 && [Pipe.Horizontal, Pipe.NorthEast, Pipe.SouthEast].contains(map[current.y][current.x - 1]) {
        coords.append(Coord(current.x - 1, current.y))
    }
    if current.x != map[0].count - 1 && [Pipe.Horizontal, Pipe.NorthWest, Pipe.SouthWest].contains(map[current.y][current.x + 1]) {
        coords.append(Coord(current.x + 1, current.y))
    }
    if current.y != 0 && [Pipe.Vertical, Pipe.SouthEast, Pipe.SouthWest].contains(map[current.y - 1][current.x]) {
        coords.append(Coord(current.x, current.y - 1))
    }
    if current.y != map.count - 1 && [Pipe.Vertical, Pipe.NorthEast, Pipe.NorthWest].contains(map[current.y + 1][current.x]) {
        coords.append(Coord(current.x, current.y + 1))
    }
    return coords
}

enum EscapeStatus: String {
    case Possible = "P"
    case Impossible = "I"
    case Loop = "L"
    case Unknown = "."
}

var mapWithAlleys: [[EscapeStatus]] = Array(repeating: Array(repeating: EscapeStatus.Unknown, count: map[0].count * 2 - 1), count: map.count * 2 - 1)


func convertNormalToAlley(_ normal: Coord) -> Coord {
    return Coord(normal.x * 2, normal.y * 2)
}

func markAlleyAsLoop(_ alleyCoord: Coord) {
    mapWithAlleys[alleyCoord.y][alleyCoord.x] = EscapeStatus.Loop
}

markAlleyAsLoop(convertNormalToAlley(start))
var current = findConnectingPipes(current: start)[0]
markAlleyAsLoop(convertNormalToAlley(current))
var prev = start
var loop_size = 1

while (current != start) {
    let alley = getAlleyCoordBetween(prev, current)
    markAlleyAsLoop(alley)
    let temp = current
    current = getNextPipe(current: current, prev: prev)
    prev = temp
    loop_size += 1
    markAlleyAsLoop(convertNormalToAlley(current))
}
markAlleyAsLoop(getAlleyCoordBetween(current, prev))

// requires them to be one unit apart, NO DIAGONALS
func getAlleyCoordBetween(_ first: Coord, _ second: Coord) -> Coord {
    if (first.x < second.x) {
        return Coord(second.x * 2 - 1, first.y * 2)
    } else if (first.x > second.x) {
        return Coord(second.x * 2 + 1, first.y * 2)
    } else if (first.y < second.y) {
        return Coord(first.x * 2, second.y * 2 - 1)
    } else if (first.y > second.y) {
        return Coord(first.x * 2, second.y * 2 + 1)
    }
    fatalError("Are they literally the same coordianate")
}

func getAllUnknownSurrounders(c: Coord) -> [Coord] {
    var listo = [Coord]()

    var availableX = [c.x]
    if c.x != 0 {
        availableX.append(c.x - 1)
    }
    if c.x < mapWithAlleys[0].count - 1 {
        availableX.append(c.x + 1)
    }
    
    var availableY = [c.y]
    if c.y != 0 {
        availableY.append(c.y - 1)
    }
    if c.y < mapWithAlleys.count - 1 {
        availableY.append(c.y + 1)
    }
    
    for x in availableX {
        for y in availableY {
            let coord = Coord(x, y)
            if c != coord && ![EscapeStatus.Loop, EscapeStatus.Impossible].contains(mapWithAlleys[y][x]) {
                listo.append(coord)
            }
        }
    }
    
    return listo
}

// to be run in the debugger
func visualizeMap(alleys: Bool, visited: Set<Coord> = Set<Coord>()) {
    for (y, row) in mapWithAlleys.enumerated() {
        var str = ""
        for (x, col) in row.enumerated() {
            if alleys || (y % 2 == 0 && x % 2 == 0) {
                if visited.contains(Coord(x, y)) {
                    str += "V"
                } else {
                    str += col.rawValue
                }
            }
        }
        print(str)
    }
}

func alleyCoordIsOnEdge(_ coord: Coord) -> Bool {
    return coord.x == 0 || coord.y == 0 || coord.y == mapWithAlleys.count - 1 || coord.x == mapWithAlleys[0].count - 1
}

func routeToEdgeExists(coord: Coord, visited: inout Set<Coord>) -> Bool {
    visited.insert(coord)
    let memoStatus = mapWithAlleys[coord.y][coord.x]
    if memoStatus == EscapeStatus.Possible {
        return true
    } else if memoStatus == EscapeStatus.Impossible {
        return false
    }
    if alleyCoordIsOnEdge(coord) {
        return true
    }
    
    for surround in getAllUnknownSurrounders(c: coord) {
        if (visited.contains(surround)) {
            continue
        }
        if routeToEdgeExists(coord: surround, visited: &visited) {
            return true
        }
    }
    return false
}

var inner_area: Set<Coord> = Set()

func runSweepForCoord(_ coord: Coord) {
    let alleyCoord = convertNormalToAlley(coord)
    var visited = Set<Coord>()
    if EscapeStatus.Loop == mapWithAlleys[alleyCoord.y][alleyCoord.x] {
        return;
    }
    let routeExists = routeToEdgeExists(coord: alleyCoord, visited: &visited)
    if routeExists {
        for c in visited {
            mapWithAlleys[c.y][c.x] = EscapeStatus.Possible
        }
    } else {
        inner_area.insert(coord)
        for c in visited {
            mapWithAlleys[c.y][c.x] = EscapeStatus.Impossible
        }
    }
}

for y in 0..<map.count {
    for x in 0..<map[0].count {
        runSweepForCoord(Coord(x, y))
    }
}

print("Farthest Away: \(loop_size / 2)")
print("Inner Area: \(inner_area.count)")
