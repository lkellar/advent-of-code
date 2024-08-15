//
//  main.swift
//  Day 19
//
//  Created by Lucas Kellar on 6/15/24.
//

import Foundation

let path = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let MIN = 1
// doesn't include 4001, 4000 and lower
let MAX = 4001

let contents: String;
do {
    // Get the contents
    contents = try String(contentsOfFile: path, encoding: .utf8)
}
catch let error as NSError {
    print(error)
    abort()
}

let splits = contents.split(separator: /\n\n/)

let workflowLines = splits[0].split(whereSeparator: \.isNewline)
let partLines = splits[1].split(whereSeparator: \.isNewline)

enum Rating: String {
    case Extremely = "x"
    case Musical = "m"
    case Aerodynamic = "a"
    case Shiny = "s"
}

enum Op: String {
    case GreaterThan = ">"
    case LessThan = "<"
    case Always = "#"
}

struct Part {
    let Extremely: Int
    let Musical: Int
    let Aerodynamic: Int
    let Shiny: Int
    
    func getRating(_ rating: Rating) -> Int {
        switch rating {
        case .Extremely:
            return Extremely
        case .Musical:
            return Musical
        case .Aerodynamic:
            return Aerodynamic
        case .Shiny:
            return Shiny
        }
    }
    
    var ratingSum: Int {
        return Extremely + Musical + Aerodynamic + Shiny
    }
}

extension Range<Int> {
    var scope: Int {
        return upperBound - lowerBound
    }
}

struct PartRange {
    var Extremely: Range<Int>
    var Musical: Range<Int>
    var Aerodynamic: Range<Int>
    var Shiny: Range<Int>
    
    var totalCombos: Int {
        return Extremely.scope * Musical.scope * Aerodynamic.scope * Shiny.scope
    }
    
    private func chopped(_ value: Int, rating: Rating, include: Bool, below: Bool) -> PartRange {
        var copy = self
        switch rating {
        case .Extremely:
            var rang: Range<Int>
            if below {
                rang = Extremely.clamped(to: MIN..<(include ? value + 1 : value))
            } else {
                rang = Extremely.clamped(to: (include ? value : value + 1)..<MAX)
            }
            copy.Extremely = rang
        case .Musical:
            var rang: Range<Int>
            if below {
                rang = Musical.clamped(to: MIN..<(include ? value + 1 : value))
            } else {
                rang = Musical.clamped(to: (include ? value : value + 1)..<MAX)
            }
            copy.Musical = rang
        case .Aerodynamic:
            var rang: Range<Int>
            if below {
                rang = Aerodynamic.clamped(to: MIN..<(include ? value + 1 : value))
            } else {
                rang = Aerodynamic.clamped(to: (include ? value : value + 1)..<MAX)
            }
            copy.Aerodynamic = rang
        case .Shiny:
            var rang: Range<Int>
            if below {
                rang = Shiny.clamped(to: MIN..<(include ? value + 1 : value))
            } else {
                rang = Shiny.clamped(to: (include ? value : value + 1)..<MAX)
            }
            copy.Shiny = rang
        }
        
        return copy
    }
    
    func getRating(_ rating: Rating) -> Range<Int> {
        switch rating {
        case .Extremely:
            return Extremely
        case .Musical:
            return Musical
        case .Aerodynamic:
            return Aerodynamic
        case .Shiny:
            return Shiny
        }
    }
    
    func choppedBelow(_ value: Int, rating: Rating, include: Bool) -> PartRange {
        return chopped(value, rating: rating, include: include, below: true)
    }
    
    func choppedAbove(_ value: Int, rating: Rating, include: Bool) -> PartRange {
        return chopped(value, rating: rating, include: include, below: false)
    }
}

struct Rule {
    let onTrue: String;
    let op: Op
    let value: Int
    let rating: Rating

    func matches(_ part: Part) -> Bool {
        switch op {
        case .GreaterThan:
            return part.getRating(rating) > value
        case .LessThan:
            return part.getRating(rating) < value
        case .Always:
            return true
        }
    }
    
    // check if there's ANY overlap
    func matchesRange(_ part: PartRange) -> Bool {
        switch op {
        case .GreaterThan:
            return part.getRating(rating).overlaps(value..<MAX)
        case .LessThan:
            return part.getRating(rating).overlaps(MIN..<value)
        case .Always:
            return true
        }
    }
}

func calculateMatchCombos(startingRange: PartRange, workflowKey: String) -> Int {
    if workflowKey == "A" {
        return startingRange.totalCombos
    } else if workflowKey == "R" {
        return 0
    }
    var range = startingRange
    let workflow = workflows[workflowKey]!
    var total = 0
    for rule in workflow {
        if rule.matchesRange(range) {
            switch rule.op {
            case .GreaterThan:
                let new = range.choppedAbove(rule.value, rating: rule.rating, include: false)
                range = range.choppedBelow(rule.value, rating: rule.rating, include: true)
                
                total += calculateMatchCombos(startingRange: new, workflowKey: rule.onTrue)
            case .LessThan:
                let new = range.choppedBelow(rule.value, rating: rule.rating, include: false)
                range = range.choppedAbove(rule.value, rating: rule.rating, include: true)
                
                total += calculateMatchCombos(startingRange: new, workflowKey: rule.onTrue)
            case .Always:
                return total + calculateMatchCombos(startingRange: range, workflowKey: rule.onTrue)
            }
        }
    }
    return total
}

var workflows: [String: [Rule]] = [:]

for workflow in workflowLines {
    let name = String(workflow.split(separator: "{").first!)
    var rules: [Rule] = []

    let ruleSplits = workflow.split(separator: "{").last!.dropLast().split(separator: ",");
    
    for ruleStr in ruleSplits {
        let colonSplits = ruleStr.split(separator: ":")
        if colonSplits.count == 1 {
            rules.append(Rule(onTrue: String(ruleStr), op: .Always, value: 0, rating: .Aerodynamic))
        }
        let onTrue = String(colonSplits.last!)
        var splits = ruleStr.split(separator: ">")
        if splits.count > 1 {
            let rating = Rating(rawValue: String(splits.first!))!
            let num = Int(splits.last!.split(separator: ":").first!)!
            rules.append(Rule(onTrue: onTrue, op: .GreaterThan, value: num, rating: rating))
            continue
        }
        splits = ruleStr.split(separator: "<")
        if splits.count > 1 {
            let rating = Rating(rawValue: String(splits.first!))!
            let num = Int(splits.last!.split(separator: ":").first!)!
            rules.append(Rule(onTrue: onTrue, op: .LessThan, value: num, rating: rating))
            continue
        }
    }
    
    workflows[name] = rules
}

let parts = partLines.map {
    let values = $0.dropLast().split(separator: ",").map { Int($0.split(separator: "=")[1])! }
    return Part(Extremely: values[0], Musical: values[1], Aerodynamic: values[2], Shiny: values[3])
}

func partOne() {
    var ratingTotal = 0

    for part in parts {
        var onTrue = "in"
        while onTrue != "A" && onTrue != "R" {
            let rules = workflows[onTrue]!
            for rule in rules {
                if rule.matches(part) {
                    onTrue = rule.onTrue
                    break
                }
            }
        }
        
        if onTrue == "A" {
            ratingTotal += part.ratingSum
        }
    }

    print("Rating Total: \(ratingTotal)")

}

if PART_TWO {
    let startingRange = PartRange(Extremely: MIN..<MAX, Musical: MIN..<MAX, Aerodynamic: MIN..<MAX, Shiny: MIN..<MAX)
    let total = calculateMatchCombos(startingRange: startingRange, workflowKey: "in")
    
    print("Scope Total: \(total)")
} else {
    partOne()
}
