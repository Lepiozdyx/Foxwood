
import SwiftUI

@MainActor
final class Game2048ViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var game: Game2048
    @Published private(set) var gameState: Game2048State = .initial
    @Published var showingPauseMenu = false
    
    // MARK: - Private Properties
    private let onGameComplete: ((Bool) -> Void)?
    private let storage: UserDefaults
    private let bestScoreKey = "game2048_bestScore"
    
    // MARK: - Computed Properties
    var score: Int {
        game.score
    }
    
    var bestScore: Int {
        game.bestScore
    }
    
    var movesCount: Int {
        game.movesCount
    }
    
    var tiles: [Tile] {
        game.getAllTiles()
    }
    
    // MARK: - Initialization
    init(onGameComplete: ((Bool) -> Void)? = nil, storage: UserDefaults = .standard) {
        self.onGameComplete = onGameComplete
        self.storage = storage
        
        // Load best score from UserDefaults
        let bestScore = storage.integer(forKey: bestScoreKey)
        
        // Initialize game with best score
        game = Game2048()
        game.bestScore = bestScore
        
        startGame()
    }
    
    // MARK: - Game Control Methods
    
    func startGame() {
        startGameplay()
    }
    
    func resetGame() {
        game.resetGame()
        gameState = .initial
        showingPauseMenu = false
        startGame()
    }
    
    func pauseGame() {
        guard case .playing = gameState else { return }
        gameState = .paused
    }
    
    func resumeGame() {
        guard case .paused = gameState else { return }
        gameState = .playing
    }
    
    func togglePauseMenu() {
        if showingPauseMenu {
            resumeGame()
        } else {
            pauseGame()
        }
        showingPauseMenu.toggle()
    }
    
    func completeGame() {
        guard case .finished(let success) = gameState else { return }
        onGameComplete?(success)
    }
    
    func cleanup() {
        // No timers to clean up anymore
    }
    
    // MARK: - Game Logic
    
    func move(_ direction: MoveDirection) {
        guard case .playing = gameState, !showingPauseMenu else { return }
        
        let moved = game.move(direction)
        
        // Update best score if needed
        if game.score > game.bestScore {
            game.bestScore = game.score
            saveBestScore()
        }
        
        // Check for game over
        if game.isGameOver {
            finishGame(success: false)
        }
        
        // Check for win
        if game.hasWon {
            finishGame(success: true)
        }
        
        // Provide haptic feedback if the move was successful
        if moved {
            HapticManager.shared.play(.light)
        }
    }
    
    // MARK: - Private Methods
    
    private func startGameplay() {
        gameState = .playing
        HapticManager.shared.play(.medium)
    }
    
    private func finishGame(success: Bool) {
        gameState = .finished(success: success)
        HapticManager.shared.play(success ? .success : .error)
    }
    
    private func saveBestScore() {
        storage.set(game.bestScore, forKey: bestScoreKey)
    }
}
