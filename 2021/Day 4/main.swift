//
//  main.swift
//  Day 4
//
//  Created by Lucas Kellar on 7/21/25.
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

var chosen: Set<Int> = []

struct BingoCard {
    let rows: [[Int]]
    
    // no diagonals
    func bingoPresent() -> Bool {
        // if a row has no falses
        if rows.contains(where: { row in row.allSatisfy({ chosen.contains($0 )}) }) {
            return true
        }
        // check cols
        for x in 0..<(rows[0].count) {
            if rows.allSatisfy({ chosen.contains($0[x]) }) {
                return true
            }
        }
        return false
    }
    
    func returnUnmarkedSum() -> Int {
        var total = 0
        for row in rows {
            for num in row {
                if !chosen.contains(num) {
                    total += num
                }
            }
        }
        return total
    }
}

var bingoCards: [BingoCard] = []

let drawings = lines[0].split(separator: ",").map { Int($0)! }

for index in stride(from: 1, to: lines.count, by: 5) {
    var rows: [[Int]] = []
    for rowNo in index..<(index + 5) {
        let row = lines[rowNo].split(whereSeparator: \.isWhitespace).map { Int($0)! }
        rows.append(row)
    }
    bingoCards.append(BingoCard(rows: rows))
}

func compute() -> Int? {
    var index = 0
    for drawing in drawings {
        chosen.insert(drawing)
        index += 1
        // can't win if under 5 drawings
        guard index > 5 else {
            continue
        }
        var removeList: [Int] = []
        for index in 0..<bingoCards.count {
            let card = bingoCards[index]
            
            if card.bingoPresent() {
                // part two is finding last winner
                if !PART_TWO || bingoCards.count == 1 {
                    return card.returnUnmarkedSum() * drawing
                } else {
                    removeList.append(index)
                }
            }
        }
        for target in removeList.reversed() {
            bingoCards.remove(at: target)
        }
    }
    return nil
}

print("Winning Score: \(compute() ?? -1)")
