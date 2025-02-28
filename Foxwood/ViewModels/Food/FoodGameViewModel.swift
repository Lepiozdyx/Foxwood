
import Combine
import SwiftUI

@MainActor
final class FoodGameViewModel: ObservableObject {
    // MARK: Published Properties
    @Published private(set) var items: [FoodItem] = []
    @Published private(set) var gameState: FoodGameState = .countdown(3)
    @Published private(set) var timeRemaining: TimeInterval = FoodGameConstants.gameDuration
    @Published private(set) var isMissTap = false
    @Published private(set) var collectedFood = 0
    
    // MARK: Private Properties
    private var countdownTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private var missTapTimer: AnyCancellable?
    private var itemGenerationTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var screenSize: CGSize = .zero
    private var safeAreaInsets: EdgeInsets = .init()
    private var onGameComplete: ((Bool) -> Void)?
    
    private var minX: CGFloat {
        safeAreaInsets.leading + FoodGameConstants.itemSize/2
    }
    
    private var maxX: CGFloat {
        screenSize.width - safeAreaInsets.trailing - FoodGameConstants.itemSize/2
    }
    
    init(onGameComplete: @escaping (Bool) -> Void) {
        self.onGameComplete = onGameComplete
        startInitialCountdown()
    }
    
    func updateLayout(size: CGSize, safeArea: EdgeInsets) {
        screenSize = size
        safeAreaInsets = safeArea
    }
    
    private func startInitialCountdown() {
        var countdown = 3
        gameState = .countdown(countdown)
        
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                countdown -= 1
                if countdown > 0 {
                    self?.gameState = .countdown(countdown)
                } else {
                    self?.countdownTimer?.cancel()
                    self?.startGame()
                }
            }
    }
    
    private func startGame() {
        gameState = .playing
        HapticManager.shared.play(.medium)
        startGameTimer()
        startGeneratingItems()
    }
    
    private func startGameTimer() {
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining <= 0.1 {
                    self.finishGame()
                } else {
                    self.timeRemaining -= 0.1
                }
            }
    }
    
    private func startGeneratingItems() {
        itemGenerationTimer = Timer.publish(
            every: FoodGameConstants.itemGenerationPeriod,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            self?.generateNewItem()
        }
    }
    
    private func generateNewItem() {
        guard items.count < FoodGameConstants.maxFallingItems else { return }
        
        let itemType = FoodItemType.randomType()
        let xPosition = CGFloat.random(in: minX...maxX)
        
        let item = FoodItem(
            type: itemType,
            position: CGPoint(x: xPosition, y: -FoodGameConstants.itemSize)
        )
        items.append(item)
    }
    
    func tapItem(_ item: FoodItem) {
        guard case .playing = gameState,
              !isMissTap,
              item.isEnabled else { return }
        
        if item.type.isEdible {
            collectedFood += 1
            HapticManager.shared.play(.light)
        } else {
            activateWarning()
            HapticManager.shared.play(.error)
            
            if collectedFood > 0 {
                collectedFood -= 1
            }
        }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isEnabled = false
        }
    }
    
    private func activateWarning() {
        isMissTap = true
        
        missTapTimer = Timer.publish(every: FoodGameConstants.missTapWarningDuration, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                self?.isMissTap = false
            }
    }
    
    private func finishGame() {
        stopTimers()
        let success = collectedFood >= FoodGameConstants.requiredFoodCount
        HapticManager.shared.play(success ? .success : .error)
        gameState = .finished(success: success)
    }
    
    func completeGame() {
        guard case .finished(let success) = gameState else { return }
        onGameComplete?(success)
    }
    
    private func stopTimers() {
        gameTimer?.cancel()
        itemGenerationTimer?.cancel()
        missTapTimer?.cancel()
        countdownTimer?.cancel()
        
        gameTimer = nil
        itemGenerationTimer = nil
        missTapTimer = nil
        countdownTimer = nil
    }
    
    func cleanup() {
        stopTimers()
    }
    
    deinit {
        cancellables.removeAll()
    }
}
