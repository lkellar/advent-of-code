//
//  main.swift
//  Day 24
//
//  Created by Lucas Kellar on 7/13/26.
//

import Foundation

var PART_TWO = false
if CommandLine.arguments.contains("two") {
    PART_TWO = true
}

// returns Z
func divide(_ w: Int, _ initZ: Int, _ addX: Int, _ addY: Int) -> Int {
    var z = initZ
    
    var x = z % 26
    z /= 26
    x += addX
    if (x == w) {
        x = 0
    } else {
        x = 1
        z *= 26
    }
    var y = w + addY
    y *= x
    z += y
    
    return z
}

func multiply(_ w: Int, _ initZ: Int, _ addX: Int, _ addY: Int) -> Int {
    var z = initZ
    //var x = z % 26
    //x += addX
    // assume that addX >= 10
    //var y = 26
    //z *= y
    z *= 26
    
    //y =
    //y *= x
    z += (w + addY)
    
    return z
}

typealias Step = (_ w: Int, _ z: Int) -> Int
let steps: [Step] = [
    {w, z in multiply(w, z, 12, 6)},
    {w, z in multiply(w, z, 10, 2)},
    {w, z in multiply(w, z, 10, 13)},
    {w, z in divide(w, z, -6, 8)},
    {w, z in multiply(w, z, 11, 13)},
    {w, z in divide(w, z, -12, 8)},
    {w, z in multiply(w, z, 11, 3)},
    {w, z in multiply(w, z, 12, 11)},
    {w, z in multiply(w, z, 12, 10)},
    {w, z in divide(w, z, -2, 8)},
    {w, z in divide(w, z, -5, 14)},
    {w, z in divide(w, z, -4, 6)},
    {w, z in divide(w, z, -4, 8)},
    {w, z in divide(w, z, -12, 2)},
]

func computeExtremeInput() -> String {
    var validOutputs = Array(repeating: Set<Int>(), count: 14)
    validOutputs[13] = [0]
    for step in stride(from: 13, through: 1, by: -1) {
        for w in 1...9 {
            for preZ in 0..<10000000 {
                let z = steps[step](w, preZ)
                if validOutputs[step].contains(z) {
                    validOutputs[step - 1].insert(preZ)
                }
            }
        }
    }
    
    print("Valid Inputs Computed")
    
    var input: [String] = []
    var z = 0
    for step in 0..<14 {
        var found = false
        for w in (
            PART_TWO ? stride(from: 1, through: 9, by: 1):
            stride(from: 9, through: 1, by: -1)
            ){
            let zCandiate = steps[step](w, z)
            if validOutputs[step].contains(zCandiate) {
                input.append(String(w))
                found = true
                z = zCandiate
                break
            }
        }
        guard found == true else {
            print("CANT FIND on step \(step)")
            exit(1)
        }
    }
    
    return input.joined()
}

print("\(PART_TWO ? "Smallest" : "Largest") Input: \(computeExtremeInput())")
