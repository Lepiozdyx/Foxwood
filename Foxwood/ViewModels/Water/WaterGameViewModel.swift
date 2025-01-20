
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
    private let segmentSpacing: CGFloat = WaterGameConstants.snakeSize
    
    // MARK: - Initialization
    init(onGameComplete: ((Bool) -> Void)? = nil) {
        self.onGameComplete = onGameComplete
    }
    
    // MARK: - Public Methods
    func updateLayout(bounds: CGRect, safeArea: EdgeInsets) {
        screenBounds = bounds
        safeAreaInsets = safeArea

        let statusBarTotalHeight = WaterGameConstants.statusBarHeight + safeArea.top
        
        gameArea = CGRect(
            x: 0,
            y: statusBarTotalHeight,
            width: bounds.width,
            height: bounds.height - statusBarTotalHeight - safeArea.bottom
        )
        
        if case .initial = gameState {
            resetPositions()
            startGame()
        }
    }
    
    func handleDrag(start: CGPoint, end: CGPoint) {
        let xDist = abs(end.x - start.x)
        let yDist = abs(end.y - start.y)
        let minDistance: CGFloat = 30
        
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
    
    func completeGame() {
        guard case .finished(let success) = gameState else { return }
        onGameComplete?(success)
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
        let previousPositions = segments.map { $0.position }
        
        let newHeadPosition = CGPoint(
            x: segments[0].position.x + movement.x,
            y: segments[0].position.y + movement.y
        )
        
        guard gameArea.contains(CGPoint(
            x: newHeadPosition.x,
            y: newHeadPosition.y
        )) else {
            finishGame()
            return
        }
        
        newSegments[0].position = newHeadPosition
        
        for i in 1..<segments.count {
            let previousSegment = previousPositions[i - 1]
            let currentSegment = previousPositions[i]
            let dx = previousSegment.x - currentSegment.x
            let dy = previousSegment.y - currentSegment.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance > segmentSpacing {
                let normalizedDx = dx / distance
                let normalizedDy = dy / distance
                let newX = previousSegment.x - normalizedDx * segmentSpacing
                let newY = previousSegment.y - normalizedDy * segmentSpacing
                
                newSegments[i].position = CGPoint(x: newX, y: newY)
            }
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
        let padding = WaterGameConstants.dropSize
        
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
        
        let direction: CGPoint
        if segments.count > 1 {
            let previousSegment = segments[segments.count - 2].position
            let dx = lastSegment.position.x - previousSegment.x
            let dy = lastSegment.position.y - previousSegment.y
            let distance = sqrt(dx * dx + dy * dy)
            direction = CGPoint(
                x: dx / distance * segmentSpacing,
                y: dy / distance * segmentSpacing
            )
        } else {
            direction = CGPoint(
                x: -self.direction.movement.x * segmentSpacing,
                y: -self.direction.movement.y * segmentSpacing
            )
        }
        
        let newPosition = CGPoint(
            x: lastSegment.position.x + direction.x,
            y: lastSegment.position.y + direction.y
        )
        
        segments.append(SnakeSegment(position: newPosition))
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
    }
}
