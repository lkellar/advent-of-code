//
//  main.swift
//  Day 2
//
//  Created by Lucas Kellar on 7/14/26.
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

let PASSWORD_REGEX = /([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)/

var validPasswords = 0
for line in lines {
    guard let match = line.wholeMatch(of: PASSWORD_REGEX) else {
        print("can't match password")
        exit(1)
    }
    let range = Int(match.output.1)!...Int(match.output.2)!
    let password = Array(match.output.4)
    // should just be one character
    let char = match.output.3.first!
    if PART_TWO {
        if (password[range.lowerBound - 1] == char) != (password[range.upperBound - 1] == char) {
            validPasswords += 1
        }
    } else {
        let charAppearances = password.count { $0 == char }
        if range.contains(charAppearances) {
            validPasswords += 1
        }
    }
}

print("Valid Passwords: \(validPasswords)")
