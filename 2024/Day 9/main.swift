//
//  main.swift
//  Day 9
//
//  Created by Lucas Kellar on 12/8/24.
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

struct Chunk {
    var count: Int
    // if value is nil, chunk represents free space
    var id: Int?
}

var chunks: [Chunk] = []
var fileCount: Int = 0

for (index, char) in contents.enumerated() {
    // ignore invalid chars like a newline
    guard let val = char.wholeNumberValue else {
        continue
    }
    // represents file
    if index % 2 == 0 {
        chunks.append(Chunk(count: val, id: index / 2))
        fileCount += 1
    } else {
        // represents free space
        chunks.append(Chunk(count: val, id: nil))
    }
}

// returns nil if no free index can be found before an another file
func findFreeIndex() -> Int? {
    var candidate: Int?
    for index in 0..<chunks.count {
        // free index found
        if chunks[index].id == nil {
            candidate = index
            break
        }
    }
    // if no free index found
    guard let candidate else {
        return nil
    }
    for index in (candidate + 1)..<chunks.count {
        // if there's another file after our free spot
        if chunks[index].id != nil {
            return candidate
        }
    }
    // if no files come after free spot, return false
    // we found the earliest free spot, so no files comes after any free spot
    return nil
}

func partOneFrag() {
    // while there's free space ahead of
    while let freeIndex = findFreeIndex()  {
        // if the first free spot is after the total size, we're done
        guard let lastFileIndex = chunks.lastIndex(where: {$0.id != nil}) else {
            print("Somehow there's no file in here")
            exit(1)
        }
        exchangeFiles(freeIndex: freeIndex, fileIndex: lastFileIndex)
    }
}

// put as much of fileIndex into the space at freeIndex as possible
func exchangeFiles(freeIndex: Array.Index, fileIndex: Array.Index) {
    // copies immune to changes below
    let freeSpot = chunks[freeIndex]
    let file = chunks[fileIndex]
    
    if freeSpot.count > file.count {
        chunks[freeIndex].count -= file.count
        chunks[fileIndex].id = nil
        chunks[fileIndex].count = file.count
        chunks.insert(file, at: freeIndex)
    } else if freeSpot.count < file.count {
        chunks[freeIndex].id = file.id
        chunks[fileIndex].count -= freeSpot.count
        // insert free space back out there
        chunks.insert(Chunk(count: freeSpot.count, id: nil), at: fileIndex + 1)
    } else {
        chunks.swapAt(freeIndex, fileIndex)
    }
}

func printState() {
    var output = ""
    for chunk in chunks {
        output += String(repeating: chunk.id?.description ?? ".", count: chunk.count)
    }
    print(output)
}

// get index of all files backwards
struct FileIterator: IteratorProtocol {
    var nextFileId: Int = fileCount

    mutating func next() -> Array.Index? {
        nextFileId -= 1
        guard nextFileId > 0 else {
            return nil
        }
        return chunks.firstIndex(where: { $0.id == nextFileId })
    }
}

func partTwoMove() {
    var iterator = FileIterator()
    while let fileIndex = iterator.next() {
        let fileSize = chunks[fileIndex].count
        // only move leftwards not rightwards
        guard let freeSpotIndex = chunks[..<fileIndex].firstIndex(where: { $0.id == nil && $0.count >= fileSize} ) else {
            // no where to put file
            continue
        }
        //printState()
        exchangeFiles(freeIndex: freeSpotIndex, fileIndex: fileIndex)
    }
    //printState()
}

func computeChecksum() -> Int {
    var total = 0
    var spot = 0
    for index in 0..<chunks.count {
        // ignore free space
        guard let id = chunks[index].id else {
            spot += chunks[index].count
            continue
        }
        for _ in 0..<chunks[index].count {
            total += (spot * id)
            spot += 1
        }
    }
    return total
}

if PART_TWO {
    partTwoMove()
} else {
    partOneFrag()
}
let checksum = computeChecksum()

print("Reorganized Checksum: \(checksum)")
