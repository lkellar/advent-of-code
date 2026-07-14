//
//  main.swift
//  Day 4
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

let passports: [[String: String]] = contents.split(separator: "\n\n")
    .map { $0.split(whereSeparator: \.isWhitespace) }
    .map { $0.reduce(into: [:], {res, next in
        let splits = next.split(separator: ":")
        res[String(splits[0])] = String(splits[1])
    }) }

let REQUIRED_FIELDS: Set<String> = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

func partOne() -> Int {
    let passportGroups = passports.map { Set($0.keys) }
    return passportGroups.count { REQUIRED_FIELDS.isSubset(of: $0) }
}

func boundedNumber(_ passport: [String: String], key: String, bounds: ClosedRange<Int>) -> Bool {
    guard let res = passport[key] else {
        return false
    }
    guard let num = Int(res) else {
        return false
    }
    
    return bounds.contains(num)
}

let HEIGHT_REGEX = /([0-9]+)(cm|in)/
let HAIR_REGEX = /#[0-9a-f]{6}/
let EYE_COLORS: Set<String> = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
let PASSPORT_NUMBER_REGEX = /[0-9]{9}/

func partTwo() -> Int {
    var total = 0
    for passport in passports {
        guard boundedNumber(passport, key: "byr", bounds: 1920...2002) else {
            continue
        }
        guard boundedNumber(passport, key: "iyr", bounds: 2010...2020) else {
            continue
        }
        guard boundedNumber(passport, key: "eyr", bounds: 2020...2030) else {
            continue
        }
        guard let height = passport["hgt"]?.wholeMatch(of: HEIGHT_REGEX) else {
            continue
        }
        guard let heightVal = Int(height.output.1) else {
            continue
        }
        if height.output.2 == "cm" {
            guard heightVal >= 150 && heightVal <= 193 else {
                continue
            }
        } else if height.output.2 == "in" {
            guard heightVal >= 59 && heightVal <= 76 else {
                continue
            }
        } else {
            continue
        }
        guard passport["hcl"]?.wholeMatch(of: HAIR_REGEX) != nil else {
            continue
        }
        guard let eyeColor = passport["ecl"] else {
            continue
        }
        guard EYE_COLORS.contains(eyeColor) else {
            continue
        }
        guard passport["pid"]?.wholeMatch(of: PASSPORT_NUMBER_REGEX) != nil else {
            continue
        }
        total += 1
    }
    return total
}

if PART_TWO {
    print("Valid Passports: \(partTwo())")
} else {
    print("Valid Passports: \(partOne())")
}
