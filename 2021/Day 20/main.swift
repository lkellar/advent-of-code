//
//  main.swift
//  Day 20
//
//  Created by Lucas Kellar on 6/26/26.
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

enum Space: Character {
    case light = "#"
    case dark = "."
    
    var flipped: Space {
        if self == .light {
            return .dark
        }
        return .light
    }
}

let lines = contents.split(whereSeparator: \.isNewline).map { Array($0).map { char in
    Space(rawValue: char)!
}}
// noticed wayy too late that in the input, zero resolves to ON, which makes the entire background light.
let algorithm = lines[0]

struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

func spacesToInt(spaces: [Space]) -> Int {
    var total = 0
    for space in spaces {
        total *= 2
        if space == .light {
            total += 1
        }
    }
    return total
}

struct Grid: CustomStringConvertible {
    let rows: [[Space]]
    let background: Space
    let width: Int
    let height: Int
    
    init(inputLines: [[Space]], background: Space) {
        // assumes same width for all
        self.width = inputLines[0].count
        self.rows = inputLines
        self.height = inputLines.count
        self.background = background
    }
    
    func getSpace(_ coord: Coord) -> Space {
        // background flips each time
        guard coord.x >= 0 && coord.x < self.width else {
            return self.background
        }
        guard coord.y >= 0 && coord.y < self.height else {
            return self.background
        }
        return self.rows[coord.y][coord.x]
    }
    
    func getLightSpaces() -> Int {
        return self.rows.reduce(0, {res, next in
            res + next.count { $0 == .light }
        })
    }
    
    func getNine(centeredAt c: Coord) -> Int {
        var spaces: [Space] = []
        for y in (c.y - 1)...(c.y + 1) {
            for x in (c.x - 1)...(c.x + 1) {
                spaces.append(getSpace(Coord(x, y)))
            }
        }
        
        return spacesToInt(spaces: spaces)
    }
    
    var description: String {
        var output: [String] = []
        for row in self.rows {
            let line = String(row.map { $0.rawValue })
            output.append(line)
        }
        return output.joined(separator: "\n")
    }
    
    func iterate() -> Grid {
        let newWidth = self.width + 4
        let newHeight = self.height + 4
        var newGrid: [[Space]] = Array(repeating: Array(repeating: .dark, count: newWidth + 1), count: newHeight + 1)
        for y in 0...newHeight {
            for x in 0...newWidth {
                let oldCoord = Coord(x - 2, y - 2)
                let nineCode = self.getNine(centeredAt: oldCoord)
                newGrid[y][x] = algorithm[nineCode]
            }
        }
        
        // in input, background flips light and dark each time,
        if algorithm[0] == .light {
            return Grid(inputLines: newGrid, background: self.background.flipped)
        } else {
            return Grid(inputLines: newGrid, background: self.background)
        }
    }
}

var grid = Grid(inputLines: Array(lines[1...]), background: .dark)

for idx in 0..<(PART_TWO ? 50 : 2) {
    grid = grid.iterate()
    print(idx)
}

print("Iteration \(PART_TWO ? 50 : 2): \(grid.getLightSpaces()) light spaces\n")
