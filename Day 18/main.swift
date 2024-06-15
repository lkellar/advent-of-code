//
//  main.swift
//  Day 18
//
//  Created by Lucas Kellar on 6/14/24.
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

let lines = contents.split(whereSeparator: \.isNewline)

enum Direction: String {
    case right = "R"
    case down = "D"
    case left = "L"
    case up = "U"
    
    init(num: Int) {
        switch num {
        case 0:
            self = .right
        case 1:
            self = .down
        case 2:
            self = .left
        case 3:
            self = .up
        default:
            print("Can't use a num higher than 3 for a dir")
            exit(1)
        }
    }
}

let allDirections: [Direction] = [.left, .up, .right, .down]

struct Instruction {
    var dir: Direction
    var dist: Int
    
    init(instr: String) {
        let splits = instr.split(separator: " ")
        
        if (PART_TWO) {
            let hexString: String = String(splits.last!)
            let start = hexString.index(hexString.startIndex, offsetBy: 2)
            // read as hex number
            var hex: Int = Int(hexString[start..<hexString.index(before:hexString.endIndex)], radix: 16)!
            // dir is last hex digit
            self.dir = Direction(num: hex % 16)
            
            // drop off last hex digit
            hex = hex >> 4;
            self.dist = hex;
        } else {
            self.dir = Direction(rawValue: String(splits[0]))!
            self.dist = Int(splits[1])!
        }
        
    }
}

struct Coord: Hashable {
    var x: Int
    var y: Int
    
    func furtherWithDirection(direc: Direction, dist: Int) -> Coord {
        switch direc {
        case .left:
            return Coord(x: x - dist, y: y)
        case .right:
            return Coord(x: x + dist, y: y)
        case .down:
            return Coord(x: x, y: y + dist)
        case .up:
            return Coord(x: x, y: y - dist)
        }
    }
}

func determine(_ first: Coord, _ second: Coord) -> Int {
    return first.x * second.y - first.y * second.x
}


let instructions = lines.map { Instruction(instr: String($0)) }
var coords: [Coord] = [Coord(x: 0, y: 0)]

let perimeter = instructions.reduce(0) {result, current in
    return result + current.dist
}

for instr in instructions {
    if let last = coords.last {
        let new = last.furtherWithDirection(direc: instr.dir, dist: instr.dist)
        coords.append(new)
    }
}

var total = 0;
for index in 1..<coords.count {
    //print(coords[index-1], coords[index])
    total += determine(coords[index - 1], coords[index])
}

total = abs(total / 2)

// area don't include the back edge of the trench
total += perimeter / 2

// also one more
total += 1

print("Total: \(total)")

