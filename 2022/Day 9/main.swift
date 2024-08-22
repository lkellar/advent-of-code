//
//  main.swift
//  Day 9
//
//  Created by Lucas Kellar on 8/22/24.
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

struct Coord: Hashable, AdditiveArithmetic, CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
    
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static var zero = Coord(x: 0, y: 0)
    
    let x: Int
    let y: Int
    
    mutating func furtherWithDirection(dir: Direction) {
        switch dir {
        case .down:
            self = Coord(x: x, y: y - 1)
        case .up:
            self = Coord(x: x, y: y + 1)
        case .right:
            self = Coord(x: x + 1, y: y)
        case .left:
            self = Coord(x: x - 1, y: y)
        }
    }
    
    var magnitude: Int {
        return abs(x) + abs(y)
    }
    
}

enum Direction: String {
    case down = "D"
    case left = "L"
    case up = "U"
    case right = "R"
}

class Rope {
    var tailVisits: Set<Coord>
    var knots: [Coord]
    
    init() {
        self.knots = Array(repeating: Coord(x: 0, y: 0), count: PART_TWO ? 10 : 2)
        self.tailVisits = Set([self.knots.last!])
    }
    
    func printRope() {
        let Xs = knots.map { $0.x }
        let Ys = knots.map { $0.y }
        let maxX = max(Xs.max()!, 3)
        let minX = min(Xs.min()!, -3)
        let maxY = max(Ys.max()!, 3)
        let minY = min(Ys.min()!, -3)
        
        var ropeMap = Array(repeating: Array(repeating: ".", count: maxX - minX + 1), count: maxY - minY + 1)
        for (index, knot) in knots.enumerated() {
            // don't overwrite
            if ropeMap[knot.y - minY][knot.x - minX] == "." {
                ropeMap[knot.y - minY][knot.x - minX] = (index == 0 ? "H" : String(index))
            }
        }
        
        print()
        for line in ropeMap.reversed() {
            print(line.joined())
        }
    }
    
    private func moveRope(dir: Direction) {
        knots[0].furtherWithDirection(dir: dir)
        for index in 1..<knots.count {
            let diff = knots[index - 1] - knots[index]
            
            // if head and tail are touching, (incl diag) don't move tail
            guard abs(diff.x) > 1 || abs(diff.y) > 1 else {
                return
            }
            
            guard abs(diff.x) + abs(diff.y) <= 4 && abs(diff.x) < 3 && abs(diff.y) < 3 else {
                print("Okay the tail can't be this far away: \(diff)")
                exit(1)
            }
            
            if diff.x == 0 {
                // move up/down with head
                if diff.y > 0 {
                    knots[index].furtherWithDirection(dir: .up)
                } else {
                    knots[index].furtherWithDirection(dir: .down)
                }
            } else if diff.y == 0 {
                if diff.x > 0 {
                    knots[index].furtherWithDirection(dir: .right)
                } else {
                    knots[index].furtherWithDirection(dir: .left)
                }
            } else {
                if diff.y > 0 {
                    knots[index].furtherWithDirection(dir: .up)
                } else {
                    knots[index].furtherWithDirection(dir: .down)
                }
                if diff.x > 0 {
                    knots[index].furtherWithDirection(dir: .right)
                } else {
                    knots[index].furtherWithDirection(dir: .left)
                }
            }
        }
        tailVisits.insert(knots.last!)
     }
    
    func moveByInstruction(dir: Direction, howMany: Int) {
        for _ in 0..<howMany {
            moveRope(dir: dir)
            //printRope()
        }
    }
}

func compute() -> Int {
    let rope = Rope()
    //rope.printRope()
    for line in lines {
        let splits = line.split(separator: " ", maxSplits: 1)
        let dir = Direction(rawValue: String(splits[0]))!
        let count = Int(splits[1])!
        rope.moveByInstruction(dir: dir, howMany: count)
    }
    return rope.tailVisits.count
}

print("Tail Unique Visits: \(compute())")
