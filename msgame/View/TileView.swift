//
//  TileView.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//

import SwiftUI
struct TileView: View {
    @Binding var tile: Tile
    @Binding var activeAlert:ActiveAlert?
    @Binding var showAlert:Bool

    var row: Int
    var column: Int
    @ObservedObject var gameModel: GameModel
    
    var body: some View {
        ZStack {
            if tile.isRevealed {
                if tile.isMine {
                    Color.red
                    Text("💥")
                        .modifier(GameTextStyle(size: 48, weight: .bold))

                } else {
                    Color.gray.opacity(tile.adjacentMines > 0 ? 0.2 : 0.05)
                    Text(tile.adjacentMines > 0 ? "\(tile.adjacentMines)" : "")
                        .modifier(GameTextStyle(size: 48, weight: .bold))
                }
            } else {
                Color.gray
                if tile.isMarked {
                    Text("💣")
                        .modifier(GameTextStyle(size: 48, weight: .bold))

                }
            }
        }
        .onTapGesture {
            
            if !tile.isMarked {
                if tile.isMine {
                    gameModel.registerMine(row: row, column: column)
                    activeAlert = .gameOver
                    showAlert = true
                } else {
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        gameModel.revealTile(row: row, column: column)
                    }
                }
                tile.isRevealed = true
                
            }
        }
        .onLongPressGesture {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            playSound(sound: "lighttap", type: "wav")

            gameModel.toggleMarkTile(row: row, column: column)

            if gameModel.checkWin() {
                activeAlert = .gameWon
                showAlert = true
            }
        }
    }
}
