//
//  main.swift
//  Day 21
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let BOARD_SIZE = 10

struct Player: Hashable {
    var position: Int
    var score: Int
    
    init(position: Int) {
        self.position = position
        self.score = 0
    }
    
    init(position: Int, score: Int) {
        self.position = position
        self.score = score
    }
    
    func move(spaces: Int) -> Player {
        let newPos = ((self.position + spaces - 1) % BOARD_SIZE) + 1
        return Player(position: newPos, score: self.score + newPos)
    }
}

class DeterministicDice {
    private var nextIdx: Int = 0
    // dice rolls 1,2,3,4,5,6. we know the dice are rolled in threes, so rolling a 1 is actually 1+2+3. 0 = 1 for index purposes
    let rolls: [Int]
    var rollCount: Int = 0
    
    init(size: Int) {
        var rolls: [Int] = Array(repeating: 0, count: size)
        assert(size >= 3)
        for idx in 1...(size - 2) {
            rolls[idx - 1] = (idx + 1) * 3
        }
        // dice wraps around
        rolls[size - 2] = (size - 1) + size + 1
        rolls[size - 1] = size + 3
        self.rolls = rolls
    }
    
    func roll() -> Int {
        let result = rolls[self.nextIdx]
        self.nextIdx += 3
        if self.nextIdx >= rolls.count {
            self.nextIdx %= rolls.count
        }
        rollCount += 3
        return result
    }
}

func partOne(p1Start: Int, p2Start: Int) -> Int {
    let dice = DeterministicDice(size: 100)
    var p1 = Player(position: p1Start)
    var p2 = Player(position: p2Start)
    
    while p1.score < 1000 && p2.score < 1000 {
        p1 = p1.move(spaces: dice.roll())
        if p1.score >= 1000 {
            break
        }
        p2 = p2.move(spaces: dice.roll())
    }
    
    return dice.rollCount * min(p1.score, p2.score)
}

struct CacheKey: Hashable {
    let p1: Player
    let p2: Player
    let p1Turn: Bool
}

var cache: [CacheKey : (Int, Int)] = [:]

func partTwo(p1: Player, p2: Player, p1Turn: Bool) -> (Int, Int) {
    let key = CacheKey(p1: p1, p2: p2, p1Turn: p1Turn)
    if let result = cache[key] {
        return result
    }
    
    assert(p1.score < 21 || p2.score < 21)
    guard p1.score < 21 else {
        return (1,0)
    }
    guard p2.score < 21 else {
        return (0,1)
    }
    
    var p1Total = 0
    var p2Total = 0
    for first in 1...3 {
        for second in 1...3 {
            for third in 1...3 {
                let roll = first + second + third
                let next = (p1Turn ? p1 : p2).move(spaces: roll)
                guard next.score < 21 else {
                    if p1Turn {
                        p1Total += 1
                    } else {
                        p2Total += 1
                    }
                    continue
                }
                let res = partTwo(p1: p1Turn ? next : p1, p2: p1Turn ? p2 : next, p1Turn: !p1Turn)
                p1Total += res.0
                p2Total += res.1
            }
        }
    }
    
    cache[key] = (p1Total, p2Total)
    return (p1Total, p2Total)
}

let p1Start = Int(lines[0].split(separator: ": ")[1])!
let p2Start = Int(lines[1].split(separator: ": ")[1])!

if PART_TWO {
    let p1 = Player(position: p1Start)
    let p2 = Player(position: p2Start)
    let res = partTwo(p1: p1, p2: p2, p1Turn: true)
    
    print("Player 1 Wins: \(res.0) - Player 2 Wins: \(res.1)")
    print("Most: \(max(res.0, res.1))")
} else {
    print("Game End Muliplication: \(partOne(p1Start: p1Start, p2Start: p2Start))")
}
