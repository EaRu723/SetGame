//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Andrea Russo on 11/19/23.
//

import SwiftUI
import Combine

class SetGameViewModel: ObservableObject {
    @Published private var game = createGame()
    @Published var elapsedTime: Int = 0

    private var timer: Timer?
    private var timerCancellable: Cancellable?
    
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
        return game.numberOfCards
    }
    
    
    var hintDisabled: Bool {
        if (game.availableHints == 0) { return true }
        else { return false }
    }
    
    // MARK: - Intent(s)
    
    func choose(card: SetGameModel.Card) {
        game.choose(card: card)
        checkGameStatus()
    }
    
    func hint() {
        game.hint()
        checkGameStatus()
    }
    
    func new() {
        // Reset the game model
        game = SetGameModel()
        startTimer()
    }
    
    private func startTimer() {
        timerCancellable?.cancel()  // Cancel any existing timer
        elapsedTime = 0
        let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timerCancellable = timerPublisher.sink(receiveValue: { [weak self] _ in
            self?.elapsedTime += 1
        })
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timer = nil
    }

    private func checkGameStatus() {
        if game.gameFinished {
            stopTimer()
        }
    }
    
}
