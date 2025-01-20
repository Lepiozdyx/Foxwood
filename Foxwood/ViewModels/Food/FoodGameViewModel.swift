
import Combine
import SwiftUI

@MainActor
final class FoodGameViewModel: ObservableObject {
    // MARK: Published Properties
    @Published private(set) var items: [FoodItem] = []
    @Published private(set) var gameState: FoodGameState = .countdown(3)
    @Published private(set) var timeRemaining: TimeInterval = FoodGameConstants.gameDuration
    @Published private(set) var isPenalty = false
    @Published private(set) var collectedFood = 0
    
    // MARK: Private Properties
    private var countdownTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private var penaltyTimer: AnyCancellable?
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
        HapticManager.shared.play(.medium)  // Средняя вибрация при старте игры
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
              !isPenalty,
              item.isEnabled else { return }
        
        if item.type.isEdible {
            collectedFood += 1
            HapticManager.shared.play(.light)
        } else {
            activatePenalty()
            HapticManager.shared.play(.error)
        }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isEnabled = false
        }
    }
    
    private func activatePenalty() {
        isPenalty = true
        penaltyTimer = Timer.publish(every: FoodGameConstants.penaltyDuration, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                self?.isPenalty = false
            }
    }
    
    private func finishGame() {
        stopTimers()
        let success = collectedFood >= FoodGameConstants.requiredFoodCount
        HapticManager.shared.play(success ? .success : .error)  // Успех/неудача в конце игры
        gameState = .finished(success: success)
    }
    
    // Добавляем новый метод для явного завершения игры
    func completeGame() {
        guard case .finished(let success) = gameState else { return }
        onGameComplete?(success)
    }
    
    private func stopTimers() {
        gameTimer?.cancel()
        itemGenerationTimer?.cancel()
        penaltyTimer?.cancel()
        countdownTimer?.cancel()
        
        gameTimer = nil
        itemGenerationTimer = nil
        penaltyTimer = nil
        countdownTimer = nil
    }
    
    func cleanup() {
        stopTimers()
    }
    
    deinit {
        cancellables.removeAll()
    }
}
