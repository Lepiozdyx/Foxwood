
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
        
        let bestScore = storage.integer(forKey: bestScoreKey)
        
        game = Game2048()
        game.bestScore = bestScore
        
        startGame()
    }
    
    // MARK: - Game Control Methods
    func startGame() {
        gameState = .playing
        HapticManager.shared.play(.medium)
    }
    
    func cleanup() {
        saveBestScore()
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
        guard case .finished(let success) = gameState else { return }
        onGameComplete?(success)
    }
    
    // MARK: - Game Logic
    func move(_ direction: MoveDirection) {
        guard case .playing = gameState, !showingPauseMenu else { return }
        
        let moved = game.move(direction)
        
        if game.score > game.bestScore {
            game.bestScore = game.score
            saveBestScore()
        }
        
        if game.isGameOver {
            finishGame(success: false)
        } else if game.hasWon {
            finishGame(success: true)
        }
        
        if moved {
            HapticManager.shared.play(.light)
        }
    }
    
    // MARK: - Private Methods
    private func finishGame(success: Bool) {
        gameState = .finished(success: success)
        HapticManager.shared.play(success ? .success : .error)
    }
    
    private func saveBestScore() {
        storage.set(game.bestScore, forKey: bestScoreKey)
    }
}
