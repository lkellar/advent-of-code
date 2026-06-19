//
//  main.swift
//  Day 12
//
//  Created by Lucas Kellar on 6/18/26 on an iPad in an airport
// 
//  literally each tree in the input is big enough to hold each present if they take up all 9 spaces 
// OR is too small to hold them even if packed perfectly, which is silly, but no need for complex algorithm
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

let splits = contents.split(separator: "\n\n").map { String($0) }

var shapeSizes: [Int] = []

for split in splits[0..<(splits.count - 1)] {
	shapeSizes.append(split.count(where: {$0 == "#"}))
}

let lines = String(splits.last!).split(whereSeparator: \.isNewline).map { String($0) }

// assume each shape is a full 3x3 and see if that would fit
func maxSizeFits(area: Int, shapeReqs: [Int]) -> Bool {
	return area >= shapeReqs.reduce(0, +) * 9
}

func minSizeFits(area: Int, shapeReqs: [Int]) -> Bool {
	var total = 0
	for idx in 0..<(shapeReqs.count) {
		total += shapeReqs[idx] * shapeSizes[idx]
	}
	
	return area >= total
}

var total = 0

for line in lines {
	let lineSplits = line.split(separator: ":")
	let dims = lineSplits[0].split(separator: "x").map { Int(String($0))! }
	
	let area = dims[0] * dims[1]
	
	let shapeReqs = lineSplits[1]
			.split(separator: " ", omittingEmptySubsequences: true)
			.map { Int(String($0))! }
			
	let maxFits = maxSizeFits(area: area, shapeReqs: shapeReqs)
	let minFits = minSizeFits(area: area, shapeReqs: shapeReqs)
	
	if !maxFits && minFits {
		print("We have a indeterminable config")
		exit(1)
	}
	
	if maxFits {
		total += 1
	}
}

print("Configurations that fit: \(total)")