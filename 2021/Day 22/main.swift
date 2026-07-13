//
//  main.swift
//  Day 22
//
//  Created by Lucas Kellar on 6/27/26.
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

let RANGE_REGEX = /(on|off) x=(-?[0-9]+)\.\.(-?[0-9]+),y=(-?[0-9]+)\.\.(-?[0-9]+),z=(-?[0-9]+)\.\.(-?[0-9]+)/

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let INIT_AREA = -50...50

class Cuboid {
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let zRange: ClosedRange<Int>
    let on: Bool
    
    // inclusion-exclusion, subtract this away when calculating volume
    var subChunks: [Cuboid] = []
    
    init(xRange: ClosedRange<Int>, yRange: ClosedRange<Int>, zRange: ClosedRange<Int>, on: Bool) {
        if PART_TWO {
            self.xRange = xRange
            self.yRange = yRange
            self.zRange = zRange
        } else {
            self.xRange = xRange.clamped(to: INIT_AREA)
            self.yRange = yRange.clamped(to: INIT_AREA)
            self.zRange = zRange.clamped(to: INIT_AREA)
        }
        self.on = on
    }
    
    // return the intersection between cuboids. Is nil if not exists
    func addIntersection(with: Cuboid) {
        guard (
            with.xRange.overlaps(self.xRange) &&
            with.yRange.overlaps(self.yRange) &&
            with.zRange.overlaps(self.zRange)
        ) else {
            return
        }
        
        let subChunk = Cuboid(
            xRange: with.xRange.clamped(to: self.xRange),
            yRange: with.yRange.clamped(to: self.yRange),
            zRange: with.zRange.clamped(to: self.zRange),
            on: !self.on
        )
        
        for chunk in self.subChunks {
            chunk.addIntersection(with: subChunk)
        }
        
        self.subChunks.append(subChunk)
    }
    
    var volume: Int {
        let initial = xRange.count * yRange.count * zRange.count
        
        let subVolume = subChunks.reduce(0, { res, next in
            return res + next.volume
        })
        
        return initial - subVolume
    }
}

let instructions: [Cuboid] = lines.map { line in
    guard let match = line.wholeMatch(of: RANGE_REGEX) else {
        print("Couldn't match \(line)")
        exit(1)
    }
    let o = match.output
    let on = o.1 == "on"
    return Cuboid(xRange: Int(o.2)!...(Int(o.3)!),
                       yRange: Int(o.4)!...(Int(o.5)!),
                       zRange: Int(o.6)!...(Int(o.7)!),
                       on: on)
}

// initially was doing a complex sub-divison of intervals, read about just the input being small enough where you could do inclusion-exclusion on the cubes, and keep track of the "vaccuums" by the overlaps, and recurse. worked way better
func computeOn() -> Int {
    var cuboids: [Cuboid] = []
    for instr in instructions {
        for cuboid in cuboids {
            cuboid.addIntersection(with: instr)
        }
        if instr.on {
            cuboids.append(instr)
        }
    }
    
    let totalOn = cuboids.reduce(0, {res, next in
        res + next.volume
    })
    
    return totalOn
}

print("Total Lights On: \(computeOn())")
