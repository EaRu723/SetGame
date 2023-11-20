//
//  SetGameApp.swift
//  SetGame
//
//  Created by Andrea Russo on 11/19/23.
//

import SwiftUI

@main
struct SetGameApp: App {
    @StateObject private var game = SetGameViewModel()
    
    var body: some Scene {
        WindowGroup {
            SetGameHome(game: game)
        }
    }
}
