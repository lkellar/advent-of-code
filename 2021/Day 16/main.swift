//
//  main.swift
//  Day 16
//
//  Created by Lucas Kellar on 7/31/25.
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

let line = contents.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

let binaryStr = line.reduce(into: "") { result, next in
    let num = Int(String(next), radix: 16)!
    result += String(String(num, radix: 2).reversed()).padding(toLength: 4, withPad: "0", startingAt: 0).reversed()
}

enum LengthType: Character {
    case bitLength = "0"
    case subpacketCount = "1"
}

enum PacketType: Int {
    case sum = 0
    case product = 1
    case minimum = 2
    case maximum = 3
    case literal = 4
    case greaterThan = 5
    case lessThan = 6
    case equalTo = 7
}

// return version sum
func parsePacket(_ packet: String, index: inout String.Index) ->Int  {
    var oldIndex: String.Index = index
    func incrementIndex(by: Int) {
        oldIndex = index
        index = packet.index(index, offsetBy: by)
    }
    var currentPacket: Int {
        return Int(String(packet[oldIndex..<index]), radix: 2)!
    }
    incrementIndex(by: 3)
    var versionSum = currentPacket
    // next 3 bits is type
    incrementIndex(by: 3)
    if currentPacket == 4 {
        var chunk: Substring
        repeat {
            incrementIndex(by: 5)
            chunk = packet[oldIndex..<index]
        } while chunk.first! != "0"
    } else {
        incrementIndex(by: 1)
        let lengthTypeId = LengthType(rawValue: packet[oldIndex])!
        if lengthTypeId == .bitLength {
            incrementIndex(by: 15)
            let subpacketBitLength = currentPacket
            let recursionStart = index
            while packet.distance(from: recursionStart, to: index) < subpacketBitLength {
                versionSum += parsePacket(packet, index: &index)
            }
            guard packet.distance(from: recursionStart, to: index) == subpacketBitLength else {
                print("wrong distance")
                exit(1)
            }
        } else {
            incrementIndex(by: 11)
            let numberOfSubpackets = currentPacket
            for _ in 0..<numberOfSubpackets {
                versionSum += parsePacket(packet, index: &index)
            }
        }
    }
    return versionSum
}

var index = binaryStr.startIndex
let versionSum = parsePacket(binaryStr, index: &index)
print("Packet Version Sum: \(versionSum)")
