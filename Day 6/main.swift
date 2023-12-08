//
//  main.swift
//  Day 6
//
//  Created by Lucas Kellar on 12/7/23.
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0.split(separator: ":", maxSplits: 1)[1]) }

var times = [Int]()
var distances = [Int]()


let part_two_predicate: (String, String.Element) -> String = {current, next in
    return current + String(next).trimmingCharacters(in: .whitespaces)
}

if PART_TWO {
    let time_combo = lines[0].reduce("", part_two_predicate)
    times = [Int(time_combo)!]
    let distance_combo = lines[1].reduce("", part_two_predicate)
    distances = [Int(distance_combo)!]
} else {
    times = lines[0].split(separator: " ").compactMap { Int($0) }
    distances = lines[1].split(separator: " ").compactMap { Int($0) }
}

func doesStratWin(time_held: Int, total_time: Int, distance_record: Int) -> Bool {
    let time_released = total_time - time_held
    return time_held * time_released > distance_record
}

func onLowerBound(time_held: Int, total_time: Int, distance_record: Int) -> Bool {
    return !(doesStratWin(time_held: time_held, total_time: total_time, distance_record: distance_record)) &&
    doesStratWin(time_held: time_held, total_time: total_time, distance_record: distance_record)
}

var total = 1
for index in 0..<times.count {
    // integer division catches edge case
    let total_time = times[index]
    let distance_record = distances[index]
    
    var left = 0
    var right = total_time
    var curr: Int
    // quick, probably not very well written, binary search
    repeat {
        curr = (left + right) / 2
        if doesStratWin(time_held: curr, total_time: total_time, distance_record: distance_record) {
            if !doesStratWin(time_held: curr - 1, total_time: total_time, distance_record: distance_record) {
                break
            } else {
                right = curr
            }
        } else {
            left = curr
        }
    } while true
    
    let win_totals = (total_time - 1) - 2 * (curr - 1)
    total *= win_totals
}

print("Win Total Timesor: \(total)")
