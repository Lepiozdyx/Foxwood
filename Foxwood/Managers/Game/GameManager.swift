
import Foundation

final class GameManager: ObservableObject {
    @Published private(set) var gameState = GameState()
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isGameOver: Bool = false
    
    private let storageManager = StorageManager.shared
    var onGameOver: ((Bool) -> Void)?
    
    func startNewGame() {
        gameState = GameState()
        isPaused = false
        isGameOver = false
    }
    
    func resetGame() {
        gameState = GameState()
        isPaused = false
        isGameOver = false
        onGameOver = nil
    }
    
    func pauseGame() {
        isPaused = true
    }
    
    func resumeGame() {
        isPaused = false
    }
    
    func addResource(_ type: ResourceType, amount: Int = 1) {
        gameState.resources[type] = (gameState.resources[type] ?? 0) + amount
        updateAchievements(for: type)
        checkWinCondition()
    }
    
    func decrementMoves() {
        guard !isGameOver else { return }
        
        gameState.movesLeft -= 1
        
        if gameState.movesLeft <= 0 {
            gameState.movesLeft = 0
            checkWinCondition()
        }
    }
    
    private func checkWinCondition() {
        guard gameState.movesLeft <= 0 && !isGameOver else { return }
        
        let hasWon = ResourceType.allCases.allSatisfy { type in
            gameState.resources[type] ?? 0 >= type.required
        }
        
        isGameOver = true
        gameState.isGameOver = true
        gameState.hasWon = hasWon
        
        if hasWon {
            updateNightsAchievement()
        }
        
        onGameOver?(hasWon)
    }
    
    private func updateAchievements(for resourceType: ResourceType) {
        let achievementType: AchievementType
        switch resourceType {
        case .wood:
            achievementType = .wood
        case .water:
            achievementType = .water
        case .food:
            achievementType = .food
        }
        
        if var achievement = storageManager.achievements.first(where: { $0.type == achievementType }) {
            achievement.progress += 1
            storageManager.updateAchievement(achievement)
        } else {
            let achievement = Achievement(type: achievementType, progress: 1)
            storageManager.updateAchievement(achievement)
        }
    }
    
    private func updateNightsAchievement() {
        if var achievement = storageManager.achievements.first(where: { $0.type == .nights }) {
            achievement.progress += 1
            storageManager.updateAchievement(achievement)
        } else {
            let achievement = Achievement(type: .nights, progress: 1)
            storageManager.updateAchievement(achievement)
        }
    }
    
    // MARK: - Resource Getters
    var woodCount: Int {
        gameState.resources[.wood] ?? 0
    }
    
    var waterCount: Int {
        gameState.resources[.water] ?? 0
    }
    
    var foodCount: Int {
        gameState.resources[.food] ?? 0
    }
    
    var movesLeft: Int {
        gameState.movesLeft
    }
}
