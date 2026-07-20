//
//  main.swift
//  Day 7
//
//  Created by Lucas Kellar on 7/20/26.
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

let BAG_START_REGEX = /^([a-z ]+) bags contain/
let BAG_CHILDREN_REGEX = /([0-9]+) ([a-z ]+) bags?,? ?/

struct Relationship {
    let name: String
    let quantity: Int
}

var bag_children: [String: [Relationship]] = [:]

for line in lines {
    guard let spec = line.prefixMatch(of: BAG_START_REGEX) else {
        print("Line does not match regex")
        exit(1)
    }
    let parent = String(spec.output.1)
    var children: [Relationship] = []
    for child in line.matches(of: BAG_CHILDREN_REGEX) {
        children.append(Relationship(name: String(child.output.2), quantity: Int(child.output.1)!))
    }
    bag_children[parent] = children
}

var bag_parents: [String: [Relationship]] = [:]
for (parent, children) in bag_children {
    for child in children {
        if bag_parents[child.name] == nil {
            bag_parents[child.name] = []
        }
        bag_parents[child.name]!.append(Relationship(name: parent, quantity: child.quantity))
    }
}

var seen: Set<String> = []
func findAllRootColors(containing: String) {
    if seen.contains(containing) {
        return
    }
    seen.insert(containing)
    guard let children = bag_parents[containing] else {
        return
    }
    for child in children {
        findAllRootColors(containing: child.name)
    }
}

var cache: [String: Int] = [:]
func findChildCountNeeded(root: String) -> Int {
    if let result = cache[root] {
        return result
    }
    seen.insert(root)
    guard let children = bag_children[root] else {
        //print("can't find children of \(containing)")
        return 0
    }
    let subCount: Int = children.reduce(0, {res, next in
        return res + next.quantity *  findChildCountNeeded(root: next.name)
    })
    let total = subCount + 1
    cache[root] = total
    return total
}

if PART_TWO {
    print("Total Bags Needed: \(findChildCountNeeded(root: "shiny gold") - 1)")
} else {
    findAllRootColors(containing: "shiny gold")
    print("All Shiny Gold Containers: \(seen.count - 1)")
}
