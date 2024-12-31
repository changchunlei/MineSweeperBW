//
//  GameBoardView.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//

import SwiftUI
struct GameBoardView: View {
    
    @Binding var selectedLevel: String?
    @StateObject private var gameModel: GameModel
    @State private var zoomScale: CGFloat = 1
    @State private var activeAlert: ActiveAlert?
    @State private var showAlert: Bool = false
    private let maxUndoCount: Int = 3
    @State private var undoCount: Int = 0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    private let timerInterval: TimeInterval = 1.0
    @State var scale = 0.6
    @State private var lastScale = 1.0
    private let minScale = 0.4
    private let maxScale = 3.0
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                adjustScale(from: state)
            }
            .onEnded { state in
                withAnimation {
                    validateScaleLimits()
                }
                lastScale = 1.0
            }
    }

    init(selectedLevel: Binding<String?>) {
        self._selectedLevel = selectedLevel
        let (rows, columns, mines) = GameBoardView.getLevelConfiguration(level: selectedLevel.wrappedValue)
        self._gameModel = StateObject(wrappedValue: GameModel(rows: rows, columns: columns, mines: mines))
    }
    @State private var timer: Timer?
    @State private var elapsedTime: Int = 0
    var body: some View {
        
        VStack{
            // vstack
            VStack{
                VStack{
                    HStack{
                        Spacer()
                        
                        let hours = Int(elapsedTime) / 3600
                        let minutes = Int(elapsedTime) / 60
                        let seconds = Int(elapsedTime) % 60
                        VStack{
                            elapsedTime < 60 ? Text("\(String(elapsedTime)) s") : Text("\(String(format: "%02d:%02d:%02d", hours, minutes, seconds))")
                        }.padding()
                        Spacer()
                        Button("End Game") {
                            selectedLevel = nil
                        }
                        Spacer()
                        Text("💣: \(gameModel.minesLeft)")
                            .padding()
                        Spacer()
                        
                    }// hstack
                    .frame(width: 400)
                }
                gameBoard
                    .scaleEffect(zoomScale)
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            zoomScale = min(max(value, 0.5), 3)
                        }
                    )
                    .gesture(
                        SimultaneousGesture(
                            magnification,
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { value in
                                    lastOffset = offset
                                }
                        )
                    )
            }
            .navigationTitle("Minesweeper")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .scaleEffect(scale)
            .offset(offset)
            .animation(.easeInOut, value: scale)
            
            .alert(isPresented: $showAlert) {
                timer?.invalidate()
                return createAlert()
            }
            .onAppear {
                startTimer(reset: true) // Restart the timer
            }
        }
        
    }
    
    func adjustScale(from state: MagnificationGesture.Value) {
        let delta = state / lastScale
        scale *= delta
        lastScale = state
    }
    
    func getMinimumScaleAllowed() -> CGFloat {
        return max(scale, minScale)
    }
    
    func getMaximumScaleAllowed() -> CGFloat {
        return min(scale, maxScale)
    }
    
    func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }

    private func startTimer(reset: Bool = false) {
        if reset { elapsedTime = 0 }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            elapsedTime += Int(timerInterval)
        }
    }
    
    private var gameBoard: some View {
        VStack {
            ForEach(0..<gameModel.board.count, id: \.self) { row in
                rowView(for: row)
            }
        }
    }
    
    private func rowView(for row: Int) -> some View {
        HStack {
            ForEach(0..<gameModel.board[row].count, id: \.self) { column in
                tileView(for: row, column: column)
            }
        }
    }
    
    private func tileView(for row: Int, column: Int) -> some View {
        TileView(tile: $gameModel.board[row][column], activeAlert: $activeAlert, showAlert: $showAlert, row: row, column: column, gameModel: gameModel)
            .frame(width: 60, height: 60)
            .cornerRadius(4)
    }
    
    private func undoLastMove() {
        gameModel.undoLastMove()
        undoCount += 1
    }

        private func createAlert() -> Alert {
        if activeAlert == .gameOver {
            playSound(sound: "error", type: "mp3")
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
            return Alert(
                title: Text("Game Over"),
                message: Text("Mine Exploded! Restart?"),
                primaryButton: .default(Text("Restart")) {
                    restartGame()
                },
                secondaryButton: undoCount < maxUndoCount ? .default(Text("Undo(\(maxUndoCount - undoCount))")) {
                    undoLastMove()
                    startTimer(reset: false)
                } : .cancel()
            )
        } else {
            playSound(sound: "win", type: "mp3")
            return Alert(
                title: Text("Congratulations"),
                message: Text("You Win! Play Again?"),
                primaryButton: .default(Text("Restart")) {
                    restartGame()
                },
                secondaryButton: .cancel()
            )
        }
    }

        private func restartGame() {
        let (rows, columns, mines) = GameBoardView.getLevelConfiguration(level: selectedLevel)
        gameModel.reset(rows: rows, columns: columns, mines: mines)
        undoCount = 0 // Reset undo count
        startTimer(reset: true) // Restart the timer
    }
    
    static func getLevelConfiguration(level: String?) -> (Int, Int, Int) {
        switch level {
        case "Easy":
            return (9, 9, 10)
        case "Normal":
            return (16, 16, 40)
        case "Hard":
            return (16, 30, 99)
        case "Master":
            return (24, 30, 180)
        default:
            return (9, 9, 10)
        }
    }
}

#Preview {
    GameBoardView(selectedLevel: .constant("Normal"))
}
