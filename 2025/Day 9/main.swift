//
//  main.swift
//  Day 9
//  Mostly copied from Day 8
//
//  Created by Lucas Kellar on 12/9/25.
//

import Foundation
import Algorithms

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

let coords = contents.split(whereSeparator: \.isNewline).map { line in
    let splits = line.split(separator: ",").map { Int($0)! }
    return Coord(splits[0], splits[1])
}

struct Coord: AdditiveArithmetic {
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static var zero = Coord(0,0)
    
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

// undirected
struct Line: Equatable {
    let from: Coord
    let to: Coord
    
    init(_ from: Coord, _ to: Coord) {
        self.from = from
        self.to = to
        // only can change in one dimension
        assert(from.x == to.x || from.y == to.y)
    }
    
    var delta: Coord {
        return to - from
    }
    
    var xRange: ClosedRange<Int> {
        min(from.x, to.x)...max(from.x, to.x)
    }
    
    var yRange: ClosedRange<Int> {
        min(from.y, to.y)...max(from.y, to.y)
    }
    
    func intersects(with: Line) -> Bool {
        let delta = self.delta
        let withDelta = with.delta
        // if they both run up down / left right,
        if delta.x == 0 && withDelta.x == 0 {
            return false
        }
        if delta.y == 0 && withDelta.y == 0 {
            return false
        }
        let horizontalLine = delta.x == 0 ? with : self
        let verticalLine = delta.y == 0 ? with : self
        assert(horizontalLine != verticalLine)
        
        return horizontalLine.xRange.contains(verticalLine.from.x) && verticalLine.yRange.contains(horizontalLine.from.y)
    }
}

struct Rectangle {
    let firstCorner: Coord
    let secondCorner: Coord
    
    var shrinked: Rectangle? {
        let minX = min(firstCorner.x, secondCorner.x)
        let maxX = max(firstCorner.x, secondCorner.x)
        
        let minY = min(firstCorner.y, secondCorner.y)
        let maxY = max(firstCorner.y, secondCorner.y)
        
        // heuristic: don't consider really narrow rectangles, makes it easier for us to calculate
        if maxX - minX < 2 || maxY - minY < 2 {
            return nil
        }
        
        return Rectangle(firstCorner: Coord(minX + 1, minY + 1), secondCorner: Coord(maxX - 1, maxY - 1))
    }
    
    var edges: [Line] {
        // include extra first corner for adjacent pairs
        let corners = [firstCorner, Coord(firstCorner.x, secondCorner.y), secondCorner, Coord(secondCorner.x, firstCorner.y), firstCorner]
        return corners.adjacentPairs().map { Line($0, $1)}
    }
    
    var area: Int {
        let delta = secondCorner - firstCorner
        // include both areas
        return (abs(delta.x) + 1) * (abs(delta.y) + 1)
    }
}

var rectangles: [Rectangle] = []
rectangles.reserveCapacity((coords.count * (coords.count + 1)) / 2)

for outerIndex in 0..<coords.count {
    let outer = coords[outerIndex]
    for innerIndex in (outerIndex + 1)..<coords.count {
        let inner = coords[innerIndex]
        let rectangle = Rectangle(firstCorner: outer, secondCorner: inner)
        rectangles.append(rectangle)
    }
}

rectangles.sort {
    return $0.area > $1.area
}


print("Most Area (excluding tiles): \(rectangles.first!.area)")

var lines: [Line] = []
for pair in coords.adjacentPairs() {
    lines.append(Line(pair.0, pair.1))
}
lines.append(Line(coords.last!, coords.first!))

for rectangle in rectangles {
    if let shrinked = rectangle.shrinked {
        var intersectionFound = false
        for edge in shrinked.edges {
            if lines.contains(where: { $0.intersects(with: edge) }) {
                intersectionFound = true
                break
            }
        }
        if !intersectionFound {
            print("Most area (within tiles): \(rectangle.area)")
            exit(0)
        }
    }
}
