
import SwiftUI

@MainActor
final class TicTacToeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var game: TicTacToe
    @Published private(set) var gameState: TicTacToeGameState = .initial
    @Published var showingPauseMenu = false
    
    // MARK: - Private Properties
    private let onGameComplete: ((Bool) -> Void)?
    
    // MARK: - Computed Properties
    var currentPlayer: Player {
        game.currentPlayer
    }
    
    var cells: [TicTacCell] {
        game.getAllCells()
    }
    
    var isGameOver: Bool {
        game.isGameOver
    }
    
    var winner: Player? {
        game.winner
    }
    
    // MARK: - Initialization
    init(onGameComplete: ((Bool) -> Void)? = nil) {
        self.onGameComplete = onGameComplete
        self.game = TicTacToe()
        startGame()
    }
    
    // MARK: - Game Control Methods
    func startGame() {
        gameState = .playing
        HapticManager.shared.play(.medium)
    }
    
    func resetGame() {
        game.resetGame()
        gameState = .initial
        showingPauseMenu = false
        startGame()
    }
    
    func togglePauseMenu() {
        if showingPauseMenu {
            gameState = .playing
        } else {
            gameState = .paused
        }
        showingPauseMenu.toggle()
    }
    
    func completeGame() {
        guard case .finished(let winner) = gameState else { return }
        let isSuccessful = winner != nil
        
        onGameComplete?(isSuccessful)
    }
    
    // MARK: - Game Logic
    func makeMove(at position: TicTacCell.Position) {
        guard case .playing = gameState, !showingPauseMenu else { return }
        
        let moved = game.makeMove(at: position)
        
        if moved {
            HapticManager.shared.play(.light)
            
            if game.isGameOver {
                finishGame()
            }
        }
    }
    
    // MARK: - Private Methods
    private func finishGame() {
        gameState = .finished(winner: game.winner)
        
        if game.winner != nil {
            HapticManager.shared.play(.success)
        } else {
            HapticManager.shared.play(.error)
        }
    }
}
