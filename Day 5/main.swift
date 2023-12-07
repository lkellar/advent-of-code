//
//  main.swift
//  Day 5
//
//  Created by Lucas Kellar on 12/6/23.
//

// I know there's like a hundred exclaimation points and forced unwrapping and while I would never do that in production, it only needs to work here once, so cutting corners seems okay
// part two will throw an error and crash when it is done but it works!
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

// was gonna say Range but i don't know if swift handles names collisions by yelling at me (preferred) or silently breaking everything (not preferred)
struct PlantRange {
    let sourceBegin: Int
    let destinationBegin: Int
    let length: Int
}

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let seeds = lines[0].split(separator: ":", maxSplits: 1)[1].split(separator: " ").map {Int($0)!}

// dynamic dictionary for the bit
var word_dict = [String: String]()
var dict_dict = [String: [PlantRange]]()

var current_word = "seed"

// already processed first line
for line in lines[1...] {
    if line.first!.isWholeNumber {
        let splits = line.split(separator: " ")
        // mmmmmm forced unwrapping and so much casting
        // probably some more efficient way but eh
        if dict_dict[current_word] == nil {
            dict_dict[current_word] = []
        }
        dict_dict[current_word]!.append(PlantRange(sourceBegin: Int(String(splits[1]))!, destinationBegin: Int(String(splits[0]))!, length: Int(String(splits[2]))!))
    } else {
        let splits = line.split(separator: " ", maxSplits: 1)[0].split(separator: "-")
        // mmmmmm so many exclamation points
        current_word = String(splits.first!)
        word_dict[current_word] = String(splits.last!)
    }
}

func getLocation(seed: Int) -> Int {
    var word = "seed"
    var number = seed
    while word != "location" {
        if let range = dict_dict[word]!.first(where: {$0.sourceBegin <= number && ($0.sourceBegin + $0.length) > number}) {
            number = range.destinationBegin + (number - range.sourceBegin)
        }
        word = word_dict[word]!
    }
    return number
}

var reverse_word_dict = word_dict.keys.reduce(into: [String: String](), {result, key in
    result[word_dict[key]] = key
})

let start = 0
let TASK_LIMIT = 20

func computeLocationToSeed(_ index: Int) async throws -> Int {
    var word = "location"
    var number = index
    repeat {
        word = await reverse_word_dict[word]!
        if let range = await dict_dict[word]!.first(where: {$0.destinationBegin <= number && ($0.destinationBegin + $0.length) > number}) {
            number = range.sourceBegin + (number - range.destinationBegin)
        }
    } while (word != "seed")
    for (begin, length) in stride(from: 0, to: seeds.count - 1, by: 2).lazy.map({(seeds[$0], seeds[$0 + 1])}) {
        if (begin..<(begin+length)).contains(number) {
            return index
        }
    }
    return -1
}

// returns the true lowest location
func validateLowestLocation(_ index: Int) async throws -> Int {
    var number = index
    while try! await computeLocationToSeed(number - 1) != -1 {
        number -= 1
    }
    return number
}

func generateTask(index: Int, largest_location: Int) async throws -> Int {
    if index % 1000000 == 0 {
        print("Index \(index) reached")
    }
    
    let result = try! await computeLocationToSeed(index)
    
    if result != -1 {
        let true_lowest = try! await validateLowestLocation(result)
        print("Lowest Location: \(true_lowest)")
        throw CancellationError()
    }

    let next = index + TASK_LIMIT;
    if next < largest_location {
        return next
    } else {
        return -1
    }
}

func partTwo(largest_location: Int) async {
    await withThrowingTaskGroup(of: Int.self) { group in
        for index in start..<(start + TASK_LIMIT) {
            group.addTask {
                try await generateTask(index: index, largest_location: largest_location)
            }
        }
        
        while let result = try! await group.next() {
            if result != -1 {
                group.addTask {
                    try await generateTask(index: result, largest_location: largest_location)
                }
            }
        }
    }
    print("done real")
}

if PART_TWO {
    // work backwards, still brute force though, but we can stop when we find one, don't have to compute all
    /*for key in dict_dict.keys {
        dict_dict[key] = dict_dict[key]!.sorted(by: { $0.destinationBegin < $1.destinationBegin })
    }*/
    let largest_range = dict_dict[reverse_word_dict["location"]!]!.last!
    let largest_location = largest_range.destinationBegin + largest_range.length - 1
    await partTwo(largest_location: largest_location)
    print("finally")
} else {
    var lowest_location = Int.max
    for key in dict_dict.keys {
        dict_dict[key] = dict_dict[key]!.sorted(by: { $0.sourceBegin < $1.sourceBegin })
    }
    for seed in seeds {
        let number = getLocation(seed: seed)
        if number < lowest_location {
            lowest_location = number
        }
    }

    print("Lowest First Location: \(lowest_location)")

}
