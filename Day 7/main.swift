//
//  main.swift
//  Day 7
//
//  Created by Lucas Kellar on 12/9/23.
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

let lines = contents.split(whereSeparator: \.isNewline).map { String($0) }

enum HandType: Int {
    case HighCard = 0
    case OnePair = 1
    case TwoPair = 2
    case ThreeOfKind = 3
    case FullHouse = 4
    case FourOfKind = 5
    case FiveOfKind = 6
}

enum Card: Int {
    case Joker = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    case Seven = 7
    case Eight = 8
    case Nine = 9
    case Ten = 10
    case Jack = 11
    case Queen = 12
    case King = 13
    case Ace = 14
}

var converter: [Character: Card] = [Character("2"): Card.Two, Character("3"): Card.Three, Character("4"): Card.Four, Character("5"): Card.Five, Character("6"): Card.Six, Character("7"): Card.Seven, Character("8"): Card.Eight, Character("9"): Card.Nine, Character("T"): Card.Ten, Character("J"): Card.Jack, Character("Q"): Card.Queen, Character("K"): Card.King, Character("A"): Card.Ace]

if (PART_TWO) {
    converter["J"] = Card.Joker
}

func determineHandType(hand: [Card]) -> HandType {
    var dict = [Card: Int]()
    // highest not joker
    var highest = 0
    for card in hand {
        if let val = dict[card] {
            dict[card] = val + 1
        } else {
            dict[card] = 1
        }
        if card != Card.Joker {
            highest = max(highest, dict[card]!)
        }
    }
    
    highest += dict[Card.Joker] ?? 0
    
    if highest == 5 {
        return HandType.FiveOfKind
    } else if highest == 4 {
        return HandType.FourOfKind
    } else if highest == 3 &&
                ((dict.values.filter({$0 == 3}).count == 1 && dict.values.filter({$0 == 2}).count == 1)
                 || (dict.values.filter({$0 == 2}).count == 2 && dict[Card.Joker] == 1)
                ) {
        return HandType.FullHouse
    } else if highest == 3 {
        return HandType.ThreeOfKind
    } else if dict.values.filter({ $0 == 2 }).count == 2
                || (dict[Card.Joker] == 1 && dict.values.contains(where: {$0 == 2})) {
        return HandType.TwoPair
    } else if highest == 2 {
        return HandType.OnePair
    } else {
        return HandType.HighCard
    }
}

struct Hand: Comparable {
    let hand: [Card]
    let type: HandType
    let bid: Int
    init(str: String, bid: Int) {
        hand = Array(str).map { converter[$0]! }
        type = determineHandType(hand: hand)
        self.bid = bid
    }
    
    static func < (lhs: Hand, rhs: Hand) -> Bool {
        if lhs.type != rhs.type {
            return lhs.type.rawValue < rhs.type.rawValue
        }
        for index in 0..<lhs.hand.count {
            if lhs.hand[index] != rhs.hand[index] {
                return lhs.hand[index].rawValue < rhs.hand[index].rawValue
            }
        }
        return false
    }
    
    static func == (lhs: Hand, rhs: Hand) -> Bool {
        return lhs.hand == rhs.hand
    }
}

var hands: [Hand] = lines.map {
    let chunks = $0.split(separator: " ", maxSplits: 1)
    return Hand(str: String(chunks[0]), bid: Int(chunks[1])!)
}

hands.sort()

let winnings = hands.enumerated().reduce(0, {
    return $0 + ($1.offset + 1) * $1.element.bid
})

print("Total Winnings: \(winnings)")
