//
//  main.swift
//  Day 7
//
//  Created by Lucas Kellar on 8/21/24.
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

let DIRECTORY_SIZE_THRESHOLD = 100000
let TOTAL_DISK_SIZE = 70000000
let DISK_SPACE_NEEDED = 30000000

guard lines[0] == "$ cd /" else {
    print("Assumed we're starting at the root")
    exit(1)
}

struct File {
    let name: String
    let size: Int
}

class Directory {
    var subdirectories: [String: Directory] = [:]
    var name: String
    var files: [File] = []
    var parent: Directory?
    
    init(name: String, parent: Directory?) {
        self.name = name
        self.parent = parent
    }
    
    func addDirectory(name: String) {
        subdirectories[name] = Directory(name: name, parent: self)
    }
    
    func addFile(name: String, size: Int) {
        files.append(File(name: name, size: size))
    }
    
    var size: Int {
        let fileSize = files.reduce(into: 0) { current, next in
            current += next.size
        }
        let subSize = subdirectories.values.reduce(into: 0) { current, next in
            current += next.size
        }
        
        return fileSize + subSize
    }
}

let rootDirectory = Directory(name: "/", parent: nil)

func buildFilesystem() {
    // skip cd /  as first line
    var index = 1
    var currentDir = rootDirectory
    while index < lines.count {
        let line = lines[index]
        guard line.starts(with: "$") else {
            print("Expecting command not result")
            exit(1)
        }
        if line == "$ ls" {
            index += 1
            // read all files / subfiles
            while index < lines.count && !lines[index].starts(with: "$") {
                let splits = lines[index].split(separator: " ", maxSplits: 1)
                if splits[0] == "dir" {
                    currentDir.addDirectory(name: String(splits[1]))
                } else {
                    currentDir.addFile(name: String(splits[1]), size: Int(splits[0])!)
                }
                index += 1
            }
        } else {
            guard line.starts(with: "$ cd") else {
                print("\(line) contains unknown command")
                exit(1)
            }
            if line == "$ cd /" {
                currentDir = rootDirectory
            } else if line == "$ cd .." {
                if let parent = currentDir.parent {
                    currentDir = parent
                } else {
                    print("Parent directory not found for \(currentDir.name)")
                }
            } else {
                let splits = line.split(separator: " ", maxSplits: 2)
                if let child = currentDir.subdirectories[String(splits[2])] {
                    currentDir = child
                } else {
                    print("Subdirectory \(splits[2]) not found under directory \(currentDir.name)")
                    exit(1)
                }
            }
            index += 1
        }
    }
}

// computes combined sizes of all directories smaller than threshold
func computeP1SubSizes(dir: Directory) -> Int {
    var total = 0
    // i realize there's a doubling of .size traversing and then manually traversing but the FS isn't big enough to make a difference
    if dir.size <= DIRECTORY_SIZE_THRESHOLD {
        total += dir.size
    }
    for sub in dir.subdirectories.values {
        total += computeP1SubSizes(dir: sub)
    }
    return total
}

func computeP2TargetDirectorySize(dir: Directory) -> Int? {
    if dir.size >= spaceNeededToClear {
        var smallest = dir.size
        for sub in dir.subdirectories.values {
            if let size = computeP2TargetDirectorySize(dir: sub) {
                smallest = min(size, smallest)
            }
        }
        return smallest
    }
    // if largest directory isn't big enough, how will subdirectories be big enough
    return nil
}

buildFilesystem()
let spaceNeededToClear = DISK_SPACE_NEEDED - (TOTAL_DISK_SIZE - rootDirectory.size)
guard spaceNeededToClear > 0 else {
    print("Looks like we have enough space")
    exit(1)
}

print("Part One Summed Directory Sizes: \(computeP1SubSizes(dir: rootDirectory))")
print("Part Two Smallest Directory Size to Delete: \(computeP2TargetDirectorySize(dir: rootDirectory) ?? -1)")
