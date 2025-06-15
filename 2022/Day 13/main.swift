//
//  main.swift
//  Day 13
//
//  Created by Lucas Kellar on 6/15/25.
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

func trimSplit(_ str: String) -> String {
    var result = str
    var front: Bool = false
    if str.first! == "[" {
        front = true
        result.removeFirst()
    }
    if str.last! == "]" {
        guard front else {
            print("MISMATCH")
            exit(1)
        }
        result.removeLast()
    } else if front {
        print("MISMATCH")
        exit(1)
    }
    return result
}

func getTopLevelSplits(str: String) -> [Substring] {
    var splits: [Substring] = []
    var start = str.startIndex
    var cur = start
    var withinSub: Int = 0
    while cur != str.endIndex {
        let char = str[cur]
        
        if withinSub > 0 {
            if char == "]" {
                withinSub -= 1
            }
            if char == "[" {
                withinSub += 1
            }
        } else if char == "," {
            splits.append(str[start..<cur])
            
            start = str.index(cur, offsetBy: 1)
        } else if char == "[" {
            withinSub += 1
        } else if char == "]" {
            print("UNEXPECTED CLOSE BRACKET")
            exit(1)
        }
        
        cur = str.index(cur, offsetBy: 1)
    }
    splits.append(str[start..<cur])
    return splits
}

func inRightOrder(left: String, right: String) -> Bool? {
    guard left.count > 0 else {
        if right.count == 0 {
            return nil
        }
        return true
    }
    guard right.count > 0 else {
        return false
    }
    let leftSplits = getTopLevelSplits(str: trimSplit(left))
    let rightSplits = getTopLevelSplits(str: trimSplit(right))
    
    for index in 0..<leftSplits.count {
        if index >= rightSplits.count {
            return false
        }
        var leftSplit = String(leftSplits[index])
        var rightSplit = String(rightSplits[index])
        let leftNum = Int(leftSplit)
        let rightNum = Int(rightSplit)
        
        if leftNum != nil && rightNum != nil {
            if leftNum! < rightNum! {
                return true
            }
            if leftNum! > rightNum! {
                return false
            }
        } else {
            // if one of them isn't, make some lists
            if let num = leftNum {
                leftSplit = "[\(num)]"
            }
            if let num = rightNum {
                rightSplit = "[\(num)]"
            }
            if let result = inRightOrder(left: leftSplit, right: rightSplit) {
                return result
            }
        }
    }
    if rightSplits.count > leftSplits.count {
        return true
    }
    return nil
}

func partOne() {
    var total = 0
    for index in stride(from: 0, to: lines.count, by: 2) {
        let pair = (index / 2) + 1
        guard let result =  inRightOrder(left: lines[index], right: lines[index + 1]) else {
            print("Pair \(pair) failed to process")
            exit(1)
        }
        if result {
            print("Pair \(pair) succeeded")
            total += pair
        } else {
            print("Pair \(pair) failed")
        }
    }
    print("Total: \(total)")
}

func partTwo() {
    let decoders = ["[[2]]", "[[6]]"]
    var packets = lines + decoders
    packets = packets.sorted { inRightOrder(left: $0, right: $1)! }
    let twoLoc = packets.firstIndex(of: decoders[0])! + 1
    let sixLoc = packets.firstIndex(of: decoders[1])! + 1
    print("Decoder Key: \(twoLoc * sixLoc)")
}

if PART_TWO {
    partTwo()
} else {
    partOne()
}
