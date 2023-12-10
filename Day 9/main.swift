//
//  main.swift
//  Day 9
//
//  Created by Lucas Kellar on 12/10/23.
//

import Foundation

let path = CommandLine.arguments[1]

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

var future_total = 0
var history_total = 0

for line in lines {
    var nums: [[Int]] = [line.split(separator: " ").map {Int($0)!}]
    while !(nums.last!.allSatisfy({$0 == 0})) {
        var new = [Int]()
        for index in 0..<(nums.last!.count - 1) {
            new.append(nums.last![index + 1] - nums.last![index])
        }
        nums.append(new)
    }
    
    nums[nums.count - 1].append(0)
    for index in stride(from: nums.count - 2, through: 0, by: -1) {
        nums[index].append(nums[index + 1].last! + nums[index].last!)
        nums[index].insert(nums[index].first! - nums[index + 1].first!, at: 0)
    }

    future_total += nums[0].last!
    history_total += nums[0].first!
}

print("Sum of Extrapolated Future Values: \(future_total)")
print("Sum of Extrapolated Historic Values: \(history_total)")
