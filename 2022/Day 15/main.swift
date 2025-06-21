//
//  main.swift
//  Day 15
//
//  Created by Lucas Kellar on 6/18/25.
//

import Foundation

let path = CommandLine.arguments[1]
let TARGET_Y_LINE = Int(CommandLine.arguments[2])!
let MAX_DIMENSION = TARGET_Y_LINE * 2
let MULTIPLIER = 4000000

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

let SENSOR_REGEX = /Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)/

struct Coord {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

func getDist(_ first: Coord, _ second: Coord) -> Int {
    return abs(first.x - second.x) + abs(first.y - second.y)
}

struct Sensor {
    let coord: Coord
    let closestBeacon: Coord
    
    let radius: Int
    
    init(coord: Coord, closestBeacon: Coord) {
        self.coord = coord
        self.closestBeacon = closestBeacon
        self.radius = getDist(coord, closestBeacon)
    }
}

var sensors: [Sensor] = []
var maxX: Int = Int.min
var minX: Int = Int.max

for line in lines {
    guard let match = line.wholeMatch(of: SENSOR_REGEX) else {
        print("Unable to match \(line)")
        exit(1)
    }
    let sensor = Sensor(coord: Coord(Int(match.1)!, Int(match.2)!), closestBeacon: Coord(Int(match.3)!, Int(match.4)!))
    sensors.append(sensor)
    minX = min(minX, sensor.coord.x - sensor.radius)
    maxX = max(maxX, sensor.coord.x + sensor.radius)
}

// first must have lessor or equal start index
func trySuperRange(_ first: ClosedRange<Int>, _ second: ClosedRange<Int>) -> ClosedRange<Int>? {
    guard first.overlaps(second) else {
        return nil
    }
    return first.lowerBound...max(first.upperBound, second.upperBound)
}

func computeRanges(y_line: Int) -> [ClosedRange<Int>] {
    var coveredRanges: [ClosedRange<Int>] = []
    for sensor in sensors {
        let yDiff = abs(y_line - sensor.coord.y)
        let new_radius = sensor.radius - yDiff
        if new_radius >= 0 {
            let stretch = (sensor.coord.x - new_radius)...(sensor.coord.x + new_radius)
            coveredRanges.append(stretch)
        }
    }
    coveredRanges.sort { $0.lowerBound < $1.lowerBound }
    var oldLength = coveredRanges.count
    
    repeat {
        oldLength = coveredRanges.count
        var newRanges: [ClosedRange<Int>] = [coveredRanges[0]]
        for index in 1..<coveredRanges.count {
            if let superRange = trySuperRange(newRanges.last!, coveredRanges[index]) {
                newRanges[newRanges.count - 1] = superRange
            } else {
                newRanges.append(coveredRanges[index])
            }
        }
        coveredRanges = newRanges
    } while oldLength != coveredRanges.count
    
    return coveredRanges
}

func partTwo() {
    for y_line in 0...MAX_DIMENSION {
        let ranges = computeRanges(y_line: y_line).map { $0.clamped(to: 0...MAX_DIMENSION)}
        var total = 0
        for range in ranges {
            total += range.count
        }
        
        if total != MAX_DIMENSION + 1 {
            let x = ranges[0].upperBound + 1
            let tuning = x * MULTIPLIER + y_line
            print("Tuning Frequency: \(tuning)")
            return
        }
    }
}

func partOne() -> Int {
    let ranges = computeRanges(y_line: TARGET_Y_LINE)
    var total = 0
    for range in ranges {
        total += range.count
    }
    
    var seenXs: Set<Int> = []
    for sensor in sensors {
        if sensor.closestBeacon.y == TARGET_Y_LINE && ranges.contains(where: { $0.contains(sensor.closestBeacon.x) }) {
            seenXs.insert(sensor.closestBeacon.x)
        }
    }
    total -= seenXs.count
    
    return total
}

if PART_TWO {
    partTwo()
} else {
    print("Positions w/ no Beacon: \(partOne())")
}
