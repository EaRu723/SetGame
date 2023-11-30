//
//  SetGameHome.swift
//
//
//  Created by Andrea Russo on 11/20/23.
//

import SwiftUI

struct SetGameHome: View {
    @ObservedObject var game: SetGameViewModel
    @State private var showCongratulationsPopup = false
    
    var body: some View {
        ZStack {
            Color.accentColor.opacity(backgroundOpacity).edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    TopActionBar(game: game)
                    CardGridHelper(game.cards, itemsCount: game.playingCardCount, itemRatio: cardRatio) { card in
                        GeometryReader { cardGeometry in
                            Button(action: {
                                withAnimation (.easeInOut) { game.choose(card: card) }
                            }) {
                                CardView(card)
                                    .transition(AnyTransition.offset(
                                        x: ((geometry.size.width / 2) - (cardGeometry.size.width / 2) - cardGeometry.frame(in: CoordinateSpace.global).origin.x),
                                        y: insertAnimationYOffest - geometry.size.height
                                    ).combined(with: .opacity))
                                //                                    .animation(.easeInOut)
                            }
                        }.aspectRatio(cardRatio, contentMode: .fit)
                            .transition(AnyTransition.asymmetric(insertion: .offset(x: 0, y: -geometry.size.height), removal: .offset(x: 0, y: geometry.size.height)).combined(with: .opacity))
                        //                        .animation(.easeInOut)
                    }.padding([.leading, .trailing])
                    Text("Time: \(game.elapsedTime) seconds")
                    BottomActionBar(game: game, geometry: geometry)
                }
            }
            if game.gameFinished {
                congratulationsPopup
            }
        }
    }
    
    // Define the congratulationsPopup outside the body
    var congratulationsPopup: some View {
        VStack {
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("You found all the sets in:")
                .font(.title2)
            Text("\(game.elapsedTime) seconds!")
                .font(.title2)
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    // MARK: - Drawing Constants
    private let backgroundOpacity: Double = 0.05
    private let cardRatio: CGFloat = 1.5
    private let insertAnimationYOffest: CGFloat = -100
    private let animationDuration: Double = 0.5
}

struct SetGameView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SetGameHome(game: SetGameViewModel())
        }
    }
}
