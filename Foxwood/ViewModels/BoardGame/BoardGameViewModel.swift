//
//  BoardGameViewModel.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import Foundation
import SwiftUI

final class BoardGameViewModel: ObservableObject {
    @Published private(set) var cells: [[Cell]] = []
    @Published private(set) var currentLayout: Int = 0
    @Published var showingPauseMenu = false
    @Published private(set) var pendingResourceCell: (position: Cell.Position, type: CellType)? = nil
    
    private let gameManager: GameManager
    
    var gameState: GameState { gameManager.gameState }
    var isPaused: Bool { gameManager.isPaused }
    var isResourcePending: Bool { pendingResourceCell != nil }
    
    init(gameManager: GameManager = GameManager()) {
        self.gameManager = gameManager
        setupNewGame()
        
        gameManager.onGameOver = { hasWon in
            print("Game Over, Won: \(hasWon)")
        }
    }
    
    func setupNewGame() {
        createBoard()
        gameManager.startNewGame()
        // Убеждаемся, что меню паузы скрыто при начале новой игры
        showingPauseMenu = false
    }
    
    func resetGame() {
        gameManager.resetGame()
        // Сбрасываем все состояния
        showingPauseMenu = false
        pendingResourceCell = nil
        setupNewGame()
    }
    
    private func createBoard() {
        // Create board from current layout
        var newCells: [[Cell]] = []
        let layout = BoardConfiguration.layouts[currentLayout]
        
        for row in 0..<BoardConfiguration.boardSize {
            var rowCells: [Cell] = []
            for column in 0..<BoardConfiguration.boardSize {
                let index = row * BoardConfiguration.boardSize + column
                let position = Cell.Position(row: row, column: column)
                let cell = Cell(position: position, type: layout[index])
                rowCells.append(cell)
            }
            newCells.append(rowCells)
        }
        
        cells = newCells
        
        // Prepare next layout
        currentLayout = (currentLayout + 1) % BoardConfiguration.layouts.count
    }
    
    func revealCell(at position: Cell.Position) -> CellType? {
        // Если есть незавершенная мини-игра, запрещаем открывать новые клетки
        guard !isPaused && pendingResourceCell == nil,
              position.row >= 0 && position.row < BoardConfiguration.boardSize,
              position.column >= 0 && position.column < BoardConfiguration.boardSize,
              !cells[position.row][position.column].isRevealed else {
            return nil
        }
        
        var updatedCells = cells
        updatedCells[position.row][position.column].isRevealed = true
        cells = updatedCells
        
        let cellType = cells[position.row][position.column].type
        
        switch cellType {
        case .empty:
            break // No moves deducted
        case .web:
            gameManager.decrementMoves()
        case .wood, .water, .mushroom, .berries:
            gameManager.decrementMoves()
            // Сохраняем информацию о ресурсной клетке, которую нужно обработать
            pendingResourceCell = (position, cellType)
        }
        
        return cellType
    }
    
    func handleResourceGameCompletion(success: Bool) {
        guard let resource = pendingResourceCell else { return }
        
        // Mark the cell as completed regardless of the game outcome
        var updatedCells = cells
        updatedCells[resource.position.row][resource.position.column].isCompleted = true
        cells = updatedCells
        
        // Add resource only if the game was won
        if success {
            switch resource.type {
            case .wood:
                gameManager.addResource(.wood)
            case .water:
                gameManager.addResource(.water)
            case .mushroom, .berries:
                gameManager.addResource(.food)
            default:
                break
            }
        }
        
        // Clear the pending resource
        pendingResourceCell = nil
    }
    
    func togglePauseMenu() {
        if showingPauseMenu {
            resumeGame()
        } else {
            pauseGame()
        }
        showingPauseMenu.toggle()
    }
    
    func pauseGame() {
        gameManager.pauseGame()
    }
    
    func resumeGame() {
        gameManager.resumeGame()
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
