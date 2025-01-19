//
//  GameManager.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import Foundation

final class GameManager: ObservableObject {
    @Published private(set) var gameState = GameState()
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isGameOver: Bool = false
    
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
        onGameOver?(hasWon)
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
