//  SetGameMode.swift
//  SetGame
//
//  Created by Andrea Russo on 11/19/23.
//

import Foundation

struct SetGameModel {
    // MARK: - User Accessible Variables
    // playing cards
    private(set) var cards: [Card] = Array<Card>()
    var remainingCardCount: Int {
        get { 81 - nextPlayingCardIndex - matchedCardCount }
    }
    var availableHints: Int {
        get { potentialSets.count }
    }
    private(set) var nextPlayingCardIndex: Int = 12
    private(set) var gameFinished: Bool = false
    
    // MARK: - Private Variables

    private var matchedCardCount: Int = 0
    private var numberOfCards = 12
    private var foundSets: Set<Set<Card>> = []

    private var chosenCards: [Card] = Array<Card>()
    private var wrongSetCards: [Card] = Array<Card>()
    private var hintedCards: [Card] = Array<Card>()
    private var hintingIndex: Int?
    private var potentialSets: [[Card]] = Array<Array<Card>>()
    
    // MARK: - New Game
    init() {
        for number in CardFeature.allCases {
            for color in CardFeature.allCases {
                for shape in CardFeature.allCases {
                    for fill in CardFeature.allCases {
                        cards.append(Card(number: number, color: color, shape: shape, fill: fill))
                    }
                }
            }
        }
        cards.shuffle()
        for index in 0..<numberOfCards {
            cards[index].state = .playing
        }
        potentialSets = findAllSetIndices()
    }
    
    // MARK: Intent 1 - Choose a Card
    mutating func choose(card: Card) {
        // reset wrong sets upon any interaction
        resetWrongSet()
        
        let chosenCardIndex = cards.firstIndex(matching: card)!
        cards[chosenCardIndex].isChosen.toggle()
        
        // if the card is now chosen
        if (cards[chosenCardIndex].isChosen) {
            // matching card state
            chosenCards.append(cards[chosenCardIndex])
            
            // See if it is a match
            if (chosenCards.count == 3) {
                
                // reset the hint upon 3 chosen cards regardless of match
                resetHintedSet()
                
                let chosenSet = Set(chosenCards)
                if !foundSets.contains(chosenSet) && isMatch(cardA: chosenCards[0], cardB: chosenCards[1], cardC: chosenCards[2]) {
                    // is a match and not previously found
                    foundSets.insert(chosenSet)
                    // Reset selection of cards but leave them in play
                    chosenCards.forEach { card in
                        if let index = cards.firstIndex(matching: card) {
                            cards[index].isChosen = false
                        }
                    }
                    chosenCards.removeAll()
                    if checkIfAllSetsFound() {
                        gameFinished = true
                    }
                }
                else {
                    // not a match
                    for card in chosenCards {
                        cards[cards.firstIndex(matching: card)!].isChosen = false
                        cards[cards.firstIndex(matching: card)!].isWrongSet = true
                    }
                    wrongSetCards = chosenCards
                    chosenCards.removeAll()
                }
            }
        } else {
            // matching card state
            chosenCards.remove(at: chosenCards.firstIndex(matching: cards[chosenCardIndex])!)
        }
    }
    
    
    // MARK: Intent 3 - Show hint (loop)
    mutating func hint() {
        // reset all playing card warnings
        resetWrongSet()
        resetHintedSet()
        resetChosen()
        
        // break if no sets
        guard (potentialSets.count > 0) else { hintingIndex = nil; return }
        
        switch hintingIndex {
        // if has hinting
        case .some(let data):
            hintingIndex = data + 1
            if (hintingIndex! >= potentialSets.count) {
                hintingIndex = 0
            }
        case .none:
            hintingIndex = 0
        }
        
        // hint the 3 cards
        for card in potentialSets[hintingIndex!] {
            cards[cards.firstIndex(matching: card)!].isHinted = true
            hintedCards.append(card)
        }
    }
    
    // MARK: - check if all sets are found
    private func checkIfAllSetsFound() -> Bool {
        let allFoundSets = foundSets.flatMap { $0 }
        let uniqueFoundSets = Set(allFoundSets)
        return uniqueFoundSets.count == potentialSets.flatMap { $0 }.count
    }
    
    // MARK: - Supporting Funcs - Reset Card States
    
    private mutating func resetChosen() {
        for card in chosenCards {
            cards[cards.firstIndex(matching: card)!].isChosen = false
        }
        chosenCards.removeAll()
    }
    
    private mutating func resetWrongSet() {
        for card in wrongSetCards {
            cards[cards.firstIndex(matching: card)!].isWrongSet = false
        }
        wrongSetCards.removeAll()
    }

    private mutating func resetHintedSet() {
        for card in hintedCards {
            cards[cards.firstIndex(matching: card)!].isHinted = false
        }
        hintedCards.removeAll()
    }
    
    // MARK: - Supporting Funcs - Hints
    
    // Find all potential sets in view
    // Complexity O(n^3), max 1,080/511,920
    private mutating func findAllSetIndices() -> [[Card]] {
        resetHintedSet()
        hintingIndex = nil
        
        var matchSets = Array<Array<Card>>()
        guard nextPlayingCardIndex >= 3 else { return matchSets }
        for a in (0..<(nextPlayingCardIndex - 2)) {
            for b in ((a + 1)..<(nextPlayingCardIndex - 1)) {
                for c in ((b + 1)..<nextPlayingCardIndex) {
                    if (isMatch(cardA: cards[a], cardB: cards[b], cardC: cards[c])) {
                        matchSets.append([cards[a], cards[b], cards[c]])
                    }
                }
            }
        }
        return matchSets
    }
    
    // MARK: - Supporting Funcs - Matching Set
    
    // Return true if given three cards are a set
    private func isMatch(cardA: Card, cardB: Card, cardC: Card) -> Bool {
        if !isSet([cardA.number, cardB.number, cardC.number]) { return false }
        if !isSet([cardA.color, cardB.color, cardC.color]) { return false }
        if !isSet([cardA.shape, cardB.shape, cardC.shape]) { return false }
        if !isSet([cardA.fill, cardB.fill, cardC.fill]) { return false }
        return true
    }
    
    // Return true if given three features are a set
    private func isSet(_ features: Array<CardFeature>) -> Bool {
        var a = 0, b = 0, c = 0
        for feature in features {
            switch feature {
            case .featureA: a += 1
            case .featureB: b += 1
            case .featureC: c += 1
            }
        }
        return !(a == 2 || b == 2 || c == 2)
    }
    
    // MARK: - Struct and Enum
    
    struct Card: Identifiable, Hashable {
        var id = UUID()
        
        var number: CardFeature
        var color: CardFeature
        var shape: CardFeature
        var fill: CardFeature
        
        // Source of truth
        var state: CardState = .fresh
        
        // In the view highlights
        var isWrongSet: Bool = false
        var isChosen: Bool = false
        var isHinted: Bool = false
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)  // Assuming 'id' is unique for each card
        }
    }
    
    // Card lifecycle fresh -> playing -> matched
    enum CardState: Equatable {
        case fresh, playing, matched, foundSet
    }

    // Three card features for each category: number, color, shape, or fill style
    enum CardFeature: CaseIterable {
        case featureA, featureB, featureC
    }
}
