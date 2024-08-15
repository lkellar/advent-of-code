//
//  main.swift
//  Day 12
//
//  Created by Lucas Kellar on 12/15/23.
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

let lines = contents.split(whereSeparator: \.isNewline).map {
    let splits = $0.split(separator: " ", maxSplits: 1)
    var statuses = splits[0].map { Status(rawValue: $0)! }
    if PART_TWO {
        let duplicates = Array(repeating: statuses, count: 4)
        statuses = duplicates.reduce(into: statuses, {result, curr in
            result += [Status.Unknown] + curr
        })
    }
    var manifest = splits[1].split(separator: ",").map { Int($0)! }
    if PART_TWO {
        manifest = Array(repeating: manifest, count: 5).flatMap {$0}
    }
    return (statuses, manifest)
}

enum Status: Character {
    case Operational = "."
    case Damaged = "#"
    case Unknown = "?"
}

struct MemoParam: Hashable {
    let statuses: [Status]
    let remaining_groups: [Int]
    let current_group_size: Int
}

var memo = [MemoParam: Int]()

// inspired by someone's kid, William
// was using a different recursion that considered the whole line and updated a "how many fixed" parameter
// but that was harder to memoize
func calcPermutations(statuses: [Status], remaining_groups: [Int], current_group_size: Int) -> Int {
    let param = MemoParam(statuses: statuses, remaining_groups: remaining_groups, current_group_size: current_group_size)
    if let result = memo[param] {
        return result
    }
    var answer = -1
    if statuses.count == 0 {
        if remaining_groups.count == 0 {
            answer = 1
        } else if remaining_groups.count == 1 && remaining_groups[0] == current_group_size  {
            answer = 1
        } else {
            answer = 0
        }
    } else if remaining_groups.count > 0 && remaining_groups[0] < current_group_size {
        answer = 0
    } else {
        switch statuses[0] {
        case .Damaged:
            if remaining_groups.count == 0 || current_group_size == remaining_groups[0] {
                answer = 0
            } else {
                answer = calcPermutations(statuses: Array(statuses[1...]), remaining_groups: remaining_groups, current_group_size: current_group_size + 1)
            }
        case .Operational:
            if current_group_size > 0 {
                if current_group_size != remaining_groups[0] {
                    answer = 0
                } else {
                    answer = calcPermutations(statuses: Array(statuses[1...]), remaining_groups: Array(remaining_groups[1...]), current_group_size: 0)
                }
            } else {
                answer = calcPermutations(statuses: Array(statuses[1...]), remaining_groups: remaining_groups, current_group_size: 0)
            }
        case .Unknown:
            answer = calcPermutations(statuses: [Status.Damaged] + statuses[1...], remaining_groups: remaining_groups, current_group_size: current_group_size) + calcPermutations(statuses: [Status.Operational] + statuses[1...], remaining_groups: remaining_groups, current_group_size: current_group_size)
        }
    }
    
    memo[param] = answer
    return answer
}

var perms = 0
for line in lines {
    let local = calcPermutations(statuses: line.0, remaining_groups: line.1, current_group_size: 0)
    perms += local
    print(local)
}

print()

print(perms)
