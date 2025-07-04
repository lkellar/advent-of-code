//
//  main.swift
//  Day 19
//
//  Created by Lucas Kellar on 7/3/25.
//

import Foundation

let path = CommandLine.arguments[1]

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

let TOTAL_TIME = PART_TWO ? 32 : 24

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

let BLUEPRINT_REGEX = /Blueprint ([0-9]+): Each ore[a-z ]+([0-9]+) ore.[a-zA-Z ]+([0-9]+) ore. [a-zA-Z ]+([0-9]+)[a-z ]+([0-9]+) clay. [a-zA-Z ]+([0-9]+) ore and ([0-9]+) obsidian\./

enum Resource {
    case clay
    case ore
    case obsidian
    case geode
}

var blueprints: [Blueprint] = []

struct Blueprint {
    let id: Int
    let costs: [Resource: [Resource: Int]]
}

for line in lines {
    guard let match = line.wholeMatch(of: BLUEPRINT_REGEX) else {
        print("no match")
        exit(0)
    }
    
    let costs: [Resource: [Resource: Int]] = [.ore: [.ore: Int(match.output.2)!], .clay: [.ore: Int(match.output.3)!], .obsidian: [.ore: Int(match.output.4)!, .clay: Int(match.output.5)!], .geode: [.ore: Int(match.output.6)!, .obsidian: Int(match.output.7)!]]
    blueprints.append(Blueprint(id: Int(match.output.1)!, costs: costs))
}

let allResources: [Resource] = [.clay, .ore, .obsidian, .geode]
let emptyResourcePack: [Resource: Int] = allResources.reduce(into: [:], {result, next in
    result[next] = 0
})

struct State: Hashable {
    let time: Int
    let robots: [Resource: Int]
    let resources: [Resource: Int]
    
    // heuristic
    var maxGeodePotential: Int {
        let timeLeft = TOTAL_TIME - time
        let maxRobotBuilds = (0..<timeLeft).reduce(0, +)
        return resources[.geode]! + timeLeft * robots[.geode]! + maxRobotBuilds
    }

    func step(amount: Int = 1) -> State {
        var newResources: [Resource: Int] = [:]
        for (key, value) in resources {
            newResources[key] = value + (robots[key]! * amount)
        }
        return State(time: time + amount, robots: robots, resources: newResources)
    }
    
    func tryBuildRobotAndStep(robotType: Resource, blueprint: Blueprint) -> State? {
        var newResources = self.resources
        for (resourceType, resourceCount) in blueprint.costs[robotType]! {
            newResources[resourceType] = resources[resourceType]! - resourceCount
        }
        var timeNeeded = 0
        var transitionState = State(time: time, robots: self.robots, resources: newResources)
        for (type, amount) in newResources {
            if amount < 0 {
                // can't wait it out
                if robots[type] == 0 {
                    return nil
                }
                var localTimeNeeded = abs(amount) / robots[type]!
                if abs(amount) % robots[type]! > 0 {
                    localTimeNeeded += 1
                }
                timeNeeded = max(timeNeeded, localTimeNeeded)
            }
        }
        if timeNeeded > 0 {
            let timeLeft = TOTAL_TIME - self.time
            if timeLeft < timeNeeded {
                return nil
            }
            transitionState = transitionState.step(amount: timeNeeded + 1)
        } else {
            transitionState = transitionState.step()
        }
        if transitionState.time > TOTAL_TIME {
            return nil
        }
        var newRobots = self.robots
        newRobots[robotType]! += 1
        return State(time: transitionState.time, robots: newRobots, resources: transitionState.resources)
    }
}

class BlueprintSimulator {
    let blueprint: Blueprint
    
    var bestSeen: Int = 0
    var iterations = 0
    var bestSeenHits = 0
    
    init(blueprint: Blueprint) {
        self.blueprint = blueprint
    }
    
    func printStats() {
        print("Best Seen Hits: \(bestSeenHits)")
        print("Total Iterations: \(iterations)")
    }
    
    func computeGeodes(state: State) -> Int {
        iterations += 1
        if state.maxGeodePotential < bestSeen {
            bestSeenHits += 1
            return 0
        }
        if state.time == TOTAL_TIME {
            bestSeen = max(bestSeen, state.resources[.geode]!)
            return state.resources[.geode]!
        } else if state.time == TOTAL_TIME - 1 {
            let total = state.resources[.geode]! + state.robots[.geode]!
            bestSeen = max(bestSeen, total)
            return total
        }

        var candidates: [Int] = []
        for resource in allResources {
            if let candidate = state.tryBuildRobotAndStep(robotType: resource, blueprint: self.blueprint) {
                candidates.append(computeGeodes( state: candidate))
            }
        }
        
        guard let maximum = candidates.max() else {
            return 0
        }
        return maximum
    }
}

func computeMaxGeodes(blueprint: Blueprint) -> Int {
    var initialRobots = emptyResourcePack
    initialRobots[.ore] = 1
    let initialState = State(time: 0, robots: initialRobots, resources: emptyResourcePack)
    let sim = BlueprintSimulator(blueprint: blueprint)
    let maxGeodes = sim.computeGeodes(state: initialState)
    sim.printStats()
    return maxGeodes
}

func partOne() -> Int {
    var total = 0
    var index = 0
    for blueprint in blueprints {
        print(blueprint.id)
        let geodes = computeMaxGeodes(blueprint: blueprint)
        total += blueprint.id * geodes
        index += 1
        print(geodes)
        print()
    }
    return total
}

func partTwo() -> Int {
    var total = 1
    var index = 0
    for blueprint in blueprints {
        guard index < 3 else {
            return total
        }
        print(blueprint.id)
        let geodes = computeMaxGeodes(blueprint: blueprint)
        total *= geodes
        index += 1
        print(geodes)
        print()
    }
    return total
}

if PART_TWO {
    print("Total Multiplied Scores: \(partTwo())")
} else {
    print("Total Quality Scores: \(partOne())")
}
