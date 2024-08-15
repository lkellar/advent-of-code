//
//  main.swift
//  Day 20
//
//  Created by Lucas Kellar on 6/16/24.
//

import Foundation
import DequeModule

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

let lines = contents.split(whereSeparator: \.isNewline)

let WATCHLIST_MAX_SIZE = 5

// mapping of inputs to outputs
var catalog: [String: [String]] = [:]
// mapping of outputs to inputs
var inputCatalog: [String: [String]] = [:]
var modules: [String: Module] = [:]

var watchlist: [String: [Int]] = [:]

enum Pulse {
    case high
    case low

    var stringForm: String {
        switch self {
        case .high:
            return "high"
        case .low:
            return "low"
        }
    }
}

struct Order {
    let pulse: Pulse
    let destination: String
    let source: String
}

protocol Module {
    static var char: String { get }
    var name: String { get }
    mutating func pulseIt(pulse: Pulse, source: String) -> [Order]
    func stateToString() -> String
}

extension Module {
    func packageOrders(pulse: Pulse) -> [Order] {
        return catalog[name]!.map { Order(pulse: pulse, destination: $0, source: name)}
    }
}

struct FlipFlop: Module {
    static var char: String = "%"
    var name: String
    var on: Bool = false
    
    mutating func pulseIt(pulse: Pulse, source: String) -> [Order] {
        // this only acts on low pulses
        guard pulse == .low else {
            return []
        }

        if on {
            on = false
            return packageOrders(pulse: .low)
        } else {
            on = true
            return packageOrders(pulse: .high)
        }
    }
    
    func stateToString() -> String {
        return "^\(name)-\(on)"
    }
}

struct Conjunction: Module {
    static var char: String = "&"
    var name: String
    var inputCache: [String: Pulse]
    
    mutating func pulseIt(pulse: Pulse, source: String) -> [Order] {
        inputCache[source] = pulse
        let allHigh = inputCache.allSatisfy { key, val in
            val == .high
        }
        if allHigh {
            return packageOrders(pulse: .low)
        } else {
            return packageOrders(pulse: .high)
        }
    }
    
    init(name: String, inputs: [String]) {
        self.name = name
        self.inputCache = inputs.reduce(into: [String: Pulse]()) { result, curr in
            result[curr] = .low
        }
    }

    func stateToString() -> String {
        let howMany = inputCache.values.filter { $0 == .high }.count
        return "\(howMany)/\(inputCache.values.count)"
    }
}

struct Broadcaster: Module {
    static var char: String = "broadcaster"
    var name: String
    
    mutating func pulseIt(pulse: Pulse, source: String) -> [Order] {
        return packageOrders(pulse: pulse)
    }

    func stateToString() -> String {
        return "^\(name)"
    }
}

var totalHighs = 0
var totalLows = 0
var totalPresses = 0
func extractPulses(order: Order) {
    if order.pulse == .high {
        totalHighs += 1
    } else {
        totalLows += 1
    }

    if PART_TWO  && order.pulse == .high {
        var existing = watchlist[order.source] ?? []
        if existing.count <= WATCHLIST_MAX_SIZE {
            existing.append(totalPresses)
            watchlist[order.source] = existing
        }
    }
}

// https://en.wikipedia.org/wiki/Euclidean_algorithm#Implementations
func gcd(_ first: Int, _ second: Int) -> Int {
    var a = first
    var b = second
    while b != 0 {
        let temp = b
        b = a % b
        a = temp
    }
    return a
}

// https://en.wikipedia.org/wiki/Least_common_multiple#Using_the_greatest_common_divisor
func lcm(_ a: Int, _ b: Int) -> Int {
    return a * (b / gcd(a,b))
}

/* runs on the assumption that the graph is of the following format:
 target has a single conjunction parent
 parent has SEVERAL conjunction parents

a more general solution would probably be cool but this one was a lot simpler
also assumes the several conjunction parents hit semifrequently, in theory a general algorithm 
could keep going up the chain but I didn't want to do that to be quite honest
 */ 
func calculateAnswerIfPossible(target: String) -> Int? {
    // jump two parents up
    let current = inputCatalog[inputCatalog[target]!.first!]!
    guard current.allSatisfy({ watchlist[$0]?.count ?? 0 >= WATCHLIST_MAX_SIZE }) else {
        return nil
    }
    // arbitary indexes, if the assumption is correct, subtracting any index will work
    let diffs = current.map { watchlist[$0]![2] - watchlist[$0]![1]}
    var rollingLcm = 1
    for diff in diffs {
        rollingLcm = lcm(rollingLcm, diff)
    }

    return rollingLcm
}

func pushButton() {
    totalPresses += 1
    var queue: Deque<Order> = [Order(pulse: .low, destination: "broadcaster", source: "button")]

    while !queue.isEmpty {
        let order = queue.popFirst()!
        extractPulses(order: order)

        // sometimes there's untyped modules that we just send to (like "output")
        // so make sure the module exists
        // still count the pulses even if it doesn't exist
        guard modules[order.destination] != nil else {
            continue
        }
        let newOrders = modules[order.destination]!.pulseIt(pulse: order.pulse, source: order.source)
        queue.append(contentsOf: newOrders)
    }
}

for line in lines {
    let splits = line.split(separator: #/ -> /#)
    let name = String(splits[0])
    let cleanName = String(name.trimmingPrefix(#/[^a-zA-Z\d:]/#))
    let destinations = splits[1].split(separator: #/, /#)
    
    for destination in destinations {
        var listo = inputCatalog[String(destination)] ?? []
        listo.append(cleanName)
        inputCatalog[String(destination)] = listo
    }
    
    catalog[cleanName] = destinations.map {String($0)}
}

for line in lines {
    let splits = line.split(separator: #/ -> /#)
    let name = String(splits[0])
    let cleanName = String(name.trimmingPrefix(#/[^a-zA-Z\d:]/#))
    if name == "broadcaster" {
        modules[cleanName] = Broadcaster(name: name)
    } else if name.starts(with: "%") {
        modules[cleanName] = FlipFlop(name: cleanName)
    } else if name.starts(with: "&") {
        modules[cleanName] = Conjunction(name: cleanName, inputs: inputCatalog[cleanName] ?? [])
    }
}


func printCatalogAsGraph() {
    for (key, value) in catalog {
        for val in value {
            print("\(key) \(val)")
        }
    } 
}

if PART_TWO {
    // once RX is found it'll cancel out
    while true {
        if totalPresses % 10000 == 0 {
            if let answer = calculateAnswerIfPossible(target: "rx") {
                print(answer)
                exit(0)
            }
        }
        pushButton()
    }
} else {
    for _ in 0..<1000 {
        pushButton()
    }
    
    print("Highs: \(totalHighs) - Lows: \(totalLows)")
    print("Total: \(totalHighs * totalLows)")
}
