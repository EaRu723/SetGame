//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Andrea Russo on 11/19/23.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    @Published private var game = createGame()
    
    private static func createGame() -> SetGameModel {
        return SetGameModel()
    }
    
    // MARK: - Access to model
    
    var cards: Array<SetGameModel.Card> {
        return game.cards
    }
    
    var matchesInView: Int {
        return game.availableHints
    }
    
    var gameFinished: Bool {
        return game.gameFinished
    }
    
    var playingCardCount: Int {
        return game.nextPlayingCardIndex
    }

    var remainingCards: Int {
        return game.remainingCardCount
    }
    
    
    var hintDisabled: Bool {
        if (game.availableHints == 0) { return true }
        else { return false }
    }
    
    // MARK: - Intent(s)
    
    func new() {
        game = SetGameViewModel.createGame()
    }
    
    func choose(card: SetGameModel.Card) {
        game.choose(card: card)
    }
    
    func hint() {
        game.hint()
    }
}
