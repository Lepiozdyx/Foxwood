//
//  WaterGameViewModel.swift
//  Foxwood
//
//  Created by Alex on 16.01.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class WaterGameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var gameState: WaterGameState = .initial
    @Published private(set) var segments: [SnakeSegment] = []
    @Published private(set) var waterDrop = WaterDrop(position: .zero)
    @Published private(set) var score: Int = 0
    @Published private(set) var timeRemaining: TimeInterval = WaterGameConstants.gameDuration
    @Published private(set) var direction: Direction = .down
    
    // MARK: - Private Properties
    private var gameTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private var screenBounds: CGRect = .zero
    private var safeAreaInsets: EdgeInsets = .init()
    private var gameArea: CGRect = .zero
    private let onGameComplete: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(onGameComplete: ((Bool) -> Void)? = nil) {
        self.onGameComplete = onGameComplete
    }
    
    // MARK: - Public Methods
    func updateLayout(bounds: CGRect, safeArea: EdgeInsets) {
        screenBounds = bounds
        safeAreaInsets = safeArea
        
        // Calculate game area
        let gameAreaWidth = bounds.width - safeArea.leading - safeArea.trailing - WaterGameConstants.borderPadding * 2
        let statusBarTotalHeight = WaterGameConstants.statusBarHeight + safeArea.top + WaterGameConstants.borderPadding
        let gameAreaHeight = bounds.height - statusBarTotalHeight - safeArea.bottom - WaterGameConstants.borderPadding
        
        gameArea = CGRect(
            x: safeArea.leading + WaterGameConstants.borderPadding,
            y: statusBarTotalHeight,
            width: gameAreaWidth,
            height: gameAreaHeight
        )
        
        if case .initial = gameState {
            resetPositions()
            startGame()
        }
    }
    
    func handleDrag(start: CGPoint, end: CGPoint) {
        let xDist = abs(end.x - start.x)
        let yDist = abs(end.y - start.y)
        let minDistance: CGFloat = 30 // Минимальное расстояние для срабатывания жеста
        
        guard xDist > minDistance || yDist > minDistance else { return }
        
        if start.y < end.y && yDist > xDist {
            direction = .down
        } else if start.y > end.y && yDist > xDist {
            direction = .up
        } else if start.x > end.x && yDist < xDist {
            direction = .left
        } else if start.x < end.x && yDist < xDist {
            direction = .right
        }
    }
    
    func startGame() {
        resetGame()
        startCountdown()
    }
    
    func cleanup() {
        gameTimer?.cancel()
        countdownTimer?.cancel()
    }
    
    // MARK: - Private Methods
    private func startCountdown() {
        var countdown = WaterGameConstants.countdownDuration
        gameState = .countdown(countdown)
        
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                countdown -= 1
                if countdown > 0 {
                    self?.gameState = .countdown(countdown)
                } else {
                    self?.countdownTimer?.cancel()
                    self?.startGameplay()
                }
            }
    }
    
    private func startGameplay() {
        gameState = .playing
        HapticManager.shared.play(.medium)
        
        gameTimer = Timer.publish(every: WaterGameConstants.updateInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateGameState()
            }
    }
    
    private func updateGameState() {
        guard case .playing = gameState else { return }
        
        // Update time
        if timeRemaining <= 0.1 {
            finishGame()
            return
        }
        timeRemaining -= WaterGameConstants.updateInterval
        
        // Move snake
        moveSnake()
        
        // Check collisions
        if hasCollectedDrop() {
            collectDrop()
        }
        
        if hasHitWall() {
            finishGame()
        }
    }
    
    private func moveSnake() {
        guard !segments.isEmpty else { return }
        
        var newSegments = segments
        let movement = direction.movement
        
        // Calculate new head position
        let newHeadPosition = CGPoint(
            x: segments[0].position.x + movement.x,
            y: segments[0].position.y + movement.y
        )
        
        // Check if new position is within bounds
        guard gameArea.contains(CGPoint(
            x: newHeadPosition.x,
            y: newHeadPosition.y
        )) else {
            finishGame()
            return
        }
        
        newSegments[0].position = newHeadPosition
        
        // Move body
        for i in 1..<segments.count {
            newSegments[i].position = segments[i-1].position
        }
        
        segments = newSegments
    }
    
    private func hasCollectedDrop() -> Bool {
        guard let head = segments.first else { return false }
        let distance = sqrt(
            pow(head.position.x - waterDrop.position.x, 2) +
            pow(head.position.y - waterDrop.position.y, 2)
        )
        return distance < WaterGameConstants.snakeSize
    }
    
    private func collectDrop() {
        score += 1
        HapticManager.shared.play(.light)
        generateNewDrop()
        addSegment()
    }
    
    private func hasHitWall() -> Bool {
        guard let head = segments.first else { return false }
        return !gameArea.contains(head.position)
    }
    
    private func generateNewDrop() {
        let padding = WaterGameConstants.dropSize / 2
        let randomX = CGFloat.random(
            in: (gameArea.minX + padding)...(gameArea.maxX - padding)
        )
        let randomY = CGFloat.random(
            in: (gameArea.minY + padding)...(gameArea.maxY - padding)
        )
        
        waterDrop = WaterDrop(position: CGPoint(x: randomX, y: randomY))
    }
    
    private func addSegment() {
        guard let lastSegment = segments.last else { return }
        segments.append(SnakeSegment(position: lastSegment.position))
    }
    
    private func resetPositions() {
        let centerX = gameArea.midX
        let centerY = gameArea.midY
        
        segments = [SnakeSegment(position: CGPoint(x: centerX, y: centerY))]
        generateNewDrop()
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = WaterGameConstants.gameDuration
        direction = .down
        gameState = .initial
        resetPositions()
    }
    
    private func finishGame() {
        gameTimer?.cancel()
        let success = score >= WaterGameConstants.requiredDrops
        HapticManager.shared.play(success ? .success : .error)
        gameState = .finished(success: success)
        onGameComplete?(success)
    }
}
