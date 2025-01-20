
import Foundation
import Combine
import SwiftUI

@MainActor
final class WoodGameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var gameState: WoodGameState = .initial
    @Published private(set) var indicatorPosition = IndicatorPosition(x: 0, direction: true)
    @Published private(set) var score = GameScore()
    @Published private(set) var lastHitSuccess: Bool?
    @Published private(set) var indicatorColor: Color = .green
    @Published private(set) var shakeWood: Bool = false
    
    // MARK: - Private Properties
    private var gameTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let onGameComplete: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(onGameComplete: ((Bool) -> Void)? = nil) {
        self.onGameComplete = onGameComplete
        startGame()
    }
    
    // MARK: - Public Methods
    func handleTap() {
        guard case .playing = gameState else { return }
        
        let isSuccess = IndicatorPosition.isInTargetZone(indicatorPosition.x)
        lastHitSuccess = isSuccess
        
        if isSuccess {
            HapticManager.shared.play(.success)
            shakeWood = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.shakeWood = false
            }
        } else {
            HapticManager.shared.play(.error)
            withAnimation(.easeOut(duration: 0.1)) {
                indicatorColor = .red
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.indicatorColor = .white
                }
            }
        }
        
        score.handleHit(isSuccess)
        
        if score.isGameOver {
            finishGame()
        }
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
    private func startGame() {
        startCountdown()
    }
    
    private func startCountdown() {
        var countdown = WoodGameConstants.countdownDuration
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
        
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateIndicatorPosition()
            }
    }
    
    private func updateIndicatorPosition() {
        indicatorPosition.update()
    }
    
    private func finishGame() {
        gameTimer?.cancel()
        let success = score.hasWon
        HapticManager.shared.play(success ? .success : .error)
        gameState = .finished(success: success)
    }
}

// MARK: - Computed Properties
extension WoodGameViewModel {
    var successCount: Int {
        score.currentStreak
    }
    
    var missCount: Int {
        score.missCount
    }
    
    var requiredSuccessCount: Int {
        WoodGameConstants.requiredSuccessStreak
    }
    
    var maxMissCount: Int {
        WoodGameConstants.maxMisses
    }
}
