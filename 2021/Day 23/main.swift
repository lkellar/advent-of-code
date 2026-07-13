//
//  main.swift
//  Day 23
//
//  Created by Lucas Kellar on 7/12/26.
//

import Foundation
import HeapModule

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

var lines = contents.split(whereSeparator: \.isNewline).map { String($0) }
if PART_TWO {
    lines.insert("  #D#B#A#C#", at: 3)
    lines.insert("  #D#C#B#A#", at: 3)
}

enum Amphipod: String {
    case amber = "A"
    case bronze = "B"
    case copper = "C"
    case desert = "D"
    
    var roomIdx: Int {
        switch self {
        case .amber:
            return 0
        case .bronze:
            return 1
        case .copper:
            return 2
        case .desert:
            return 3
        }
    }
    
    var energy: Int {
        switch self {
        case .amber:
            return 1
        case .bronze:
            return 10
        case .copper:
            return 100
        case .desert:
            return 1000
        }
    }
    
    var roomEntranceIdx: Int {
        return (self.roomIdx + 1) * 2
    }
}

let ROOM_TO_AMPHIPOD: [Int: Amphipod] = [0: .amber, 1: .bronze, 2: .copper, 3: .desert]

// same in spec and input, so no need to parse
let HALLWAY_LENGTH = 11
let ROOM_DEPTH = PART_TWO ? 4 : 2

typealias Room = [Amphipod]

let ALL_AMPHIPODS: [Amphipod] = [.amber, .bronze, .copper, .desert]

struct Move: Comparable {
    static func < (lhs: Move, rhs: Move) -> Bool {
        return lhs.energy < rhs.energy
    }
    
    let submarine: Submarine
    let energy: Int
}

struct Submarine: Hashable, CustomStringConvertible {
    let hallway: [Amphipod?]
    // in order from bottom to top. Last element is top of room
    let rooms: [Room]
    
    init(rooms: [Room]) {
        self.hallway = Array(repeating: nil, count: HALLWAY_LENGTH)
        self.rooms = rooms
    }
    
    init(hallway: [Amphipod?], rooms: [Room]) {
        self.hallway = hallway
        self.rooms = rooms
    }
    
    func findValidHallwaySpots(fromEntrance: Int) -> [Int] {
        var results: [Int] = []
        var next = fromEntrance - 1
        while next >= 0 && self.hallway[next] == nil {
            if next != 2 && next != 4 && next != 6 && next != 8 {
                results.append(next)
            }
            next -= 1
        }
        
        next = fromEntrance + 1
        while next < self.hallway.count && self.hallway[next] == nil {
            if next != 2 && next != 4 && next != 6 && next != 8 {
                results.append(next)
            }
            next += 1
        }
        
        return results
    }
    
    var complete: Bool {
        guard hallway.allSatisfy({$0 == nil}) else {
            return false
        }
        for amphi in ALL_AMPHIPODS {
            guard self.rooms[amphi.roomIdx].allSatisfy({$0 == amphi}) else {
                return false
            }
            guard self.rooms[amphi.roomIdx].count == ROOM_DEPTH else {
                return false
            }
        }
        return true
    }
    
    // return all valid moves and the energy required
    func allValidMoves(initialEnergy: Int) -> [Move] {
        var moves: [Move] = []
        for hallIdx in 0..<(hallway.count) {
            guard let amphi = hallway[hallIdx] else {
                continue
            }
            let roomIdx = amphi.roomIdx
            let roomEntranceIdx = amphi.roomEntranceIdx
            // can't stop outside room
            assert(roomEntranceIdx != hallIdx)
            assert(self.rooms[roomIdx].count <= ROOM_DEPTH)
            // can't move into room that is full
            guard self.rooms[roomIdx].count < ROOM_DEPTH else {
                continue
            }
            // can't be anyone in way
            if hallIdx < roomEntranceIdx {
                guard hallway[(hallIdx + 1)..<roomEntranceIdx].allSatisfy({$0 == nil}) else {
                    continue
                }
            } else {
                guard hallway[(roomEntranceIdx + 1)..<hallIdx].allSatisfy({$0 == nil}) else {
                    continue
                }
            }
            let dist = abs(roomEntranceIdx - hallIdx) + (ROOM_DEPTH - self.rooms[roomIdx].count)
            // if everything in target room are amphipod or nil
            if self.rooms[roomIdx].allSatisfy({ $0 == amphi }) {
                var newHallway = self.hallway
                newHallway[hallIdx] = nil
                var newRooms = self.rooms
                newRooms[roomIdx].append(amphi)
                assert(newRooms[roomIdx].count <= ROOM_DEPTH)
                moves.append(Move(
                    submarine: Submarine(hallway: newHallway, rooms: newRooms),
                    energy: initialEnergy + dist * amphi.energy
                ))
            }
        }
        
        for roomIdx in 0..<(rooms.count) {
            let room = rooms[roomIdx]
            let target_amphi = ROOM_TO_AMPHIPOD[roomIdx]!
            // if room full with target, ignore
            guard room.contains(where: { $0 != target_amphi }) else {
                continue
            }
            
            assert(room.count != 0)
            let amphi = room.last!
            let entranceIdx = ROOM_TO_AMPHIPOD[roomIdx]!.roomEntranceIdx
            let validSpaces = findValidHallwaySpots(fromEntrance: entranceIdx)
            for validSpace in validSpaces {
                let dist = abs(entranceIdx - validSpace) + (ROOM_DEPTH - (room.count - 1))
                var newHallway = self.hallway
                assert(newHallway[validSpace] == nil)
                newHallway[validSpace] = amphi
                var newRooms = self.rooms
                newRooms[roomIdx].removeLast()
                moves.append(Move(
                    submarine: Submarine(hallway: newHallway, rooms: newRooms),
                    energy: initialEnergy + dist * amphi.energy
                ))
            }
        }
        return moves
    }
    
    // only for part 1
    var description: String {
        var result = "#############\n#"
        for amphi in hallway {
            if let amphi = amphi {
                result += amphi.rawValue
            } else {
                result += "."
            }
        }
        result += "#\n###"
        result += self.rooms.map { $0.count == 2 ? $0[1].rawValue : "." }.joined(separator: "#")
        result += "###\n  #"
        result += self.rooms.map { $0.count >= 1 ? $0[0].rawValue : "." }.joined(separator: "#")
        result += "#  \n  #########  "
        return result
    }
}

func initializeSubmarine() -> Submarine {
    var rooms: [Room] = Array(repeating: [], count: 4)
    for idx in stride(from: lines.count - 2, through: 2, by: -1) {
        let pods = lines[idx]
            .trimmingCharacters(in: CharacterSet.whitespaces)
            .split(separator: "#")
            .map { Amphipod(rawValue: String($0))! }
        for roomIdx in 0..<(rooms.count) {
            rooms[roomIdx].append(pods[roomIdx])
        }
    }
    
    return Submarine(rooms: rooms)
}

var cache: [Submarine: Int] = [:]

func computeMinEnergy() -> Int {
    var queue: Heap<Move> = [Move(submarine: initializeSubmarine(), energy: 0)]
    var seen: Set<Submarine> = []
    
    while let next = queue.popMin() {
        guard !seen.contains(next.submarine) else {
            continue
        }
        if next.submarine.complete {
            return next.energy
        }
        seen.insert(next.submarine)
        let validMoves = next.submarine.allValidMoves(initialEnergy: next.energy)
        queue.insert(contentsOf: validMoves)
    }
    
    print("No solution found! Seen: \(seen.count)")
    exit(1)
}

print("Minimum energy required: \(computeMinEnergy())")
