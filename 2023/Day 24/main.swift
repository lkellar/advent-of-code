//
//  main.swift
//  Day 24
//
//  Created by Lucas Kellar on 7/10/24.

import Foundation

let path = CommandLine.arguments[1]
let MIN_DIM = Double(CommandLine.arguments[2])!
let MAX_DIM = Double(CommandLine.arguments[3])!

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

enum HailstoneError: Error {
    case neverInterceptsBox
}

struct Coord: Hashable, AdditiveArithmetic {
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        return Coord(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static func * (lhs: Coord, rhs: Double) -> Coord {
        return Coord(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    static func / (lhs: Coord, rhs: Double) -> Coord {
        return Coord(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    static var zero: Coord = Coord(x: 0, y: 0, z: 0)
    
    let x: Double
    let y: Double
    let z: Double

    // only considers 2D
    var withinBoundingBox: Bool {
        guard MIN_DIM <= x && x <= MAX_DIM else {
            return false
        }
        guard MIN_DIM <= y && y <= MAX_DIM else {
            return false
        }
        return true
    }
    
    var description: String { return "(\(x), \(y), \(z))" }
    
    func crossWith(other: Coord) -> Coord {
        let term_one = self.y * other.z - self.z * other.y
        let term_two = -(self.x * other.z - self.z * other.x)
        let term_three = self.x * other.y - self.y * other.x
        
        return Coord(x: term_one, y: term_two, z: term_three)
    }
    
    func dotWith(other: Coord) -> Double {
        return self.x * other.x + self.y * other.y + self.z * other.z
    }
}

struct Intercept {
    let boundary: Double
    // time to interception
    let tti: Double
}

// returns intecept boundary value and time to intercept
func findNextInterception(_ value: Double, delta: Double) -> Intercept? {
    var nextBoundary: Double?
    if delta > 0 {
        if value < MIN_DIM {
            nextBoundary = MIN_DIM
        } else if value < MAX_DIM {
            nextBoundary = MAX_DIM
        } else {
            // if moving in the positive and already passed the max boundary, we won't hit another
            nextBoundary = nil
        }
    } else {
        if value > MAX_DIM {
            nextBoundary = MAX_DIM
        } else if value > MIN_DIM {
            nextBoundary = MIN_DIM
        } else {
            // if moving in negative and already passed the min boundary, we won't hit another
            nextBoundary = nil
        }
    }

    guard let nextBoundary = nextBoundary else {
        return nil
    }

    return Intercept(boundary: nextBoundary, tti: (nextBoundary - value) / delta)
}

func findNextBoundingBoxInterception(start: Coord, deltas: Coord, considerZ: Bool = false) -> Coord? {
    guard considerZ == false else {
        print("Considering Z for bounding box interception not implemented yet")
        exit(1)
    }
    
    let xIntercept = findNextInterception(start.x, delta: deltas.x)
    let yIntercept = findNextInterception(start.y, delta: deltas.y)

    guard xIntercept != nil && yIntercept != nil else {
        return nil
    }
    guard let yIntercept = yIntercept else {
        guard let xIntercept = xIntercept else {
            print("Impossible")
            exit(1)
        }
        // ttiY doesn't exist? calculate x interception
        // x must exist because above guard didn't throw
        return Coord(x: xIntercept.boundary, y: start.y + deltas.y * xIntercept.tti, z: start.z + deltas.z * xIntercept.tti)
    }
    guard let xIntercept = xIntercept else {
        // ttiX doesn't exist? calculate y interception
        return Coord(x: start.x + deltas.x * yIntercept.tti, y: yIntercept.boundary, z: start.z + deltas.z * yIntercept.tti)
    }

    if xIntercept.tti < yIntercept.tti {
        // x interception sooner? Find that
        return Coord(x: xIntercept.boundary, y: start.y + deltas.y * xIntercept.tti, z: start.z + deltas.z * xIntercept.tti)
    } else {
        // else find the Y interception
        return Coord(x: start.x + deltas.x * yIntercept.tti, y: yIntercept.boundary, z: start.z + deltas.z * yIntercept.tti)
    }
}

struct Hailstone: AdditiveArithmetic {
    // i probably wouldn't use these for part one
    static func + (lhs: Hailstone, rhs: Hailstone) -> Hailstone {
        return Hailstone(start: lhs.start + rhs.start, end: lhs.end + rhs.end, origin: lhs.origin + rhs.origin, deltas: lhs.deltas + rhs.deltas)
    }
    
    static func - (lhs: Hailstone, rhs: Hailstone) -> Hailstone {
        Hailstone(start: lhs.start - rhs.start, end: lhs.end - rhs.end, origin: lhs.origin - rhs.origin, deltas: lhs.deltas - rhs.deltas)
    }
    
    static var zero: Hailstone = Hailstone()
    
    let origin: Coord
    let start: Coord
    let end: Coord
    var slope: Double {
        if end.x - start.x == 0 {
            return 0
        }
        return (end.y - start.y) / (end.x - start.x)
    }

    // more of a vector really
    let deltas: Coord
    
    // returns the coord of intersection if they intersect
    // borrowed from https://www.hackingwithswift.com/example-code/core-graphics/how-to-calculate-the-point-where-two-lines-intersect
    // doesn't account for Z, just leaves as whatever the first point's Z is at interception
    func intersectsStone(other: Hailstone) -> Coord? {
        precondition(Set([self.start, self.end, other.start, other.end]).count == 4, "Assumes lines don't start/end at the same spot")
        let delta1x = self.end.x - self.start.x
        let delta1y = self.end.y - self.start.y
        let delta2x = other.end.x - other.start.x
        let delta2y = other.end.y - other.start.y
        
        let delta1z = self.end.z - self.start.x
        
        let determinant = delta1x * delta2y - delta2x * delta1y
        
        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }
        
        let ab = ((self.start.y - other.start.y) * delta2x - (self.start.x - other.start.x) * delta2y) / determinant
        
        if ab > 0 && ab < 1 {
            let cd = ((self.start.y - other.start.y) * delta1x - (self.start.x - other.start.x) * delta1y) / determinant

            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                let intersectX = self.start.x + ab * delta1x
                let intersectY = self.start.y + ab * delta1y
                let zAtIntersection = self.start.z + ab * delta1z
                return Coord(x: intersectX, y: intersectY, z: zAtIntersection)
            }
        }

        // lines don't cross
        return nil
    }
    
    init() {
        self.start = .zero
        self.end = .zero
        self.origin = .zero
        self.deltas = .zero
    }
    
    init(start: Coord, end: Coord, origin: Coord, deltas: Coord) {
        self.start = start
        self.end = end
        self.origin = origin
        self.deltas = deltas
    }
    
    init(_ str: String) throws {
        let splits = str.split(separator: "@")

        let deltaNumbers = splits[1].trimmingCharacters(in: .whitespaces).split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) }

        deltas = Coord(x: deltaNumbers[0]!, y: deltaNumbers[1]!, z: deltaNumbers[2]!)

        precondition(deltas.x != 0, "DeltaX cannot be zero")
        precondition(deltas.y != 0, "DeltaY cannot be zero")

        let starts = splits[0].trimmingCharacters(in: .whitespaces).split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) }
        origin = Coord(x: starts[0]!, y: starts[1]!, z: starts[2]!)
        var localStart = origin
        while !localStart.withinBoundingBox {
            guard let next = findNextBoundingBoxInterception(start: localStart, deltas: deltas) else {
                //print("Wasn't able to see where the hailstone intercepts the bounding box:\n\t- Origin: \(origin)\n\t- Deltas: \(deltas)")
                throw HailstoneError.neverInterceptsBox
            }
            localStart = next
        }
        start = localStart

        precondition(start.x >= MIN_DIM && start.x <= MAX_DIM, "Invalid X: \(start.x) | Min X: \(MIN_DIM) | Max X: \(MAX_DIM)")
        precondition(start.y >= MIN_DIM && start.y <= MAX_DIM, "Invalid Y: \(start.y) | Min Y: \(MIN_DIM) | Max Y: \(MAX_DIM)")

        guard let end = findNextBoundingBoxInterception(start: start, deltas: deltas) else {
            print("Wasn't able to find where hailstone intercepts the bounding box again:\n\t- Origin: \(origin)\n\t- Start:  \(start)\n\t- Deltas: \(deltas)")
            exit(1)
        }
    
        self.end = end
    }
}

let lines: [Hailstone] = contents.split(whereSeparator: \.isNewline).reduce(into: []) { result, next in
    if let stone = try? Hailstone(String(next)) {
        result.append(stone)
    }
}

func computeIntersections() -> Int {
    var intersections = 0
    for outer in 0..<lines.count {
        for inner in (outer + 1)..<lines.count {
            if lines[outer].intersectsStone(other: lines[inner]) != nil {
                intersections += 1
            }
        }
    }
    return intersections
}

// solution computed with help of https://old.reddit.com/r/adventofcode/comments/18pnycy/2023_day_24_solutions/kxqjg33/
func partTwo() -> Double {
    // only need three stones,
    let stone_zero = lines[0]
    // set stone one and stone two in relative to stone zero
    let stone_one = lines[1] - stone_zero
    let stone_two = lines[2] - stone_zero
    
    print("Positions: S1: \(stone_one.origin) | S2: \(stone_two.origin)")
    print("Velocities: S1: \(stone_one.deltas) | S2: \(stone_two.deltas)")
    
    let stone_one_two_origin_cross = stone_one.origin.crossWith(other: stone_two.origin)

    let time_one_numerator = -(stone_one_two_origin_cross.dotWith(other: stone_two.deltas))
    let time_one_denominator = stone_one.deltas.crossWith(other: stone_two.origin).dotWith(other: stone_two.deltas)
    let time_one = time_one_numerator / time_one_denominator

    let time_two_numerator = -(stone_one_two_origin_cross.dotWith(other: stone_one.deltas))
    let time_two_denominator = stone_one.origin.crossWith(other: stone_two.deltas).dotWith(other: stone_one.deltas)
    let time_two = time_two_numerator / time_two_denominator

    print("T1: \(time_one) | T2: \(time_two)")
    
    precondition(time_one >= 0 && time_two >= 0, "Times cannot be negative")

    let collision_one = stone_one.origin + stone_one.deltas * time_one
    let collision_two = stone_two.origin + stone_two.deltas * time_two
    
    print("C1: \(collision_one), C2: \(collision_two)")

    let rock_velocity = (collision_two - collision_one) / (time_two - time_one)
    var rock_position = collision_one - rock_velocity * time_one
    
    print("Rock Position: \(rock_position) | Velocity: \(rock_velocity)")
    
    // deshift position
    // velocity would also need to be deshifted but we aren't using it for anything else so ignore
    rock_position = rock_position + stone_zero.origin
    
    print("New Rock Position: \(rock_position)")
    
    // for some reason it only works if each rock position is floored
    return floor(rock_position.x) + floor(rock_position.y) + floor(rock_position.z)
}


// PART_TWO handled within
if PART_TWO {
    let answer = partTwo()
    print("Sum of starting coord: \(answer)")
} else {
    let clock = ContinuousClock()
    let elapsed = clock.measure {
        let intersections = computeIntersections()
        print("\(intersections) Intersections")
    }
    print("Took \(elapsed)")
}

