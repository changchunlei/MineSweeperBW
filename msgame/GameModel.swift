//
//  GameModel.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//
import Foundation
import SwiftUI

class GameModel: ObservableObject {
    @Published var board: [[Tile]]
    private var rows: Int
    private var columns: Int
    private var mines: Int
    private var moveHistory: [(row: Int, column: Int)] = []
    @Published var markedTiles: Int = 0
    private var isFirstClick: Bool = true

    init(rows: Int, columns: Int, mines: Int) {
        self.rows = rows
        self.columns = columns
        self.mines = mines
        self.board = Array(repeating: Array(repeating: Tile(), count: columns), count: rows)
        reset(rows: rows, columns: columns, mines: mines)
    }
    
    func reset(rows: Int, columns: Int, mines: Int) {
        self.rows = rows
        self.columns = columns
        self.mines = mines
        self.isFirstClick = true
        self.board = Array(repeating: Array(repeating: Tile(), count: columns), count: rows)
    }
    
    func toggleMarkTile(row: Int, column: Int) {
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        if board[row][column].isMarked {
            board[row][column].isMarked = false
            markedTiles -= 1
        } else if markedTiles < mines {
            board[row][column].isMarked = true
            markedTiles += 1
        }
    }
    
    private func placeMines(excludingRow: Int, excludingColumn: Int) {
        var placedMines = 0
        while placedMines < mines {
            let row = Int.random(in: 0..<rows)
            let column = Int.random(in: 0..<columns)
            if !isExcluded(row: row, column: column, excludingRow: excludingRow, excludingColumn: excludingColumn) && !board[row][column].isMine {
                board[row][column].isMine = true
                placedMines += 1
            }
        }
    }

    private func isExcluded(row: Int, column: Int, excludingRow: Int, excludingColumn: Int) -> Bool {
        return (row >= excludingRow - 1 && row <= excludingRow + 1) && (column >= excludingColumn - 1 && column <= excludingColumn + 1)
    }
    
    private func calculateAdjacentMines() {
        for row in 0..<rows {
            for column in 0..<columns {
                if !board[row][column].isMine {
                    board[row][column].adjacentMines = countAdjacentMines(row: row, column: column)
                }
            }
        }
    }
    
    private func countAdjacentMines(row: Int, column: Int) -> Int {
        var count = 0
        for i in max(0, row-1)...min(rows-1, row+1) {
            for j in max(0, column-1)...min(columns-1, column+1) {
                if board[i][j].isMine {
                    count += 1
                }
            }
        }
        return count
    }
    func registerMine(row: Int, column: Int) {
        moveHistory.append((row, column))
    }
    
    func revealTile(row: Int, column: Int) {
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        guard !board[row][column].isRevealed else { return }
        
        if isFirstClick {
            placeMines(excludingRow: row, excludingColumn: column)
            calculateAdjacentMines()
            isFirstClick = false
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            if !board[row][column].isMarked {
                board[row][column].isRevealed = true
            }
        }


        if board[row][column].adjacentMines == 0 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            for i in max(0, row-1)...min(rows-1, row+1) {
                for j in max(0, column-1)...min(columns-1, column+1) {
                    if !(i == row && j == column) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.revealTile(row: i, column: j)
                        }
                    }
                }
            }
        }
    }
    
    func undoLastMove() {
        guard let lastMove = moveHistory.popLast() else { return }
        board[lastMove.row][lastMove.column].isRevealed = false
        board[lastMove.row][lastMove.column].isMarked = false
    }
    
    var minesLeft: Int {
        let markedMines = board.flatMap { $0 }.filter { $0.isMarked }.count
        return mines - markedMines
    }
    
    func checkWin() -> Bool {
        if isFirstClick {
            return false
        }

        return board.allSatisfy { row in
            row.allSatisfy { tile in
                !(tile.isMine && !tile.isMarked)
            }
        }
    }
}

struct Tile {
    var isMine: Bool = false
    var adjacentMines: Int = 0
    var isRevealed: Bool = false
    var isMarked: Bool = false
}
