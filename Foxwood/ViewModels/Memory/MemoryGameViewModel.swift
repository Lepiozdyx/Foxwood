
import SwiftUI
import Combine

@MainActor
final class MemoryGameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var gameState: MemoryGameState = .initial
    @Published private(set) var cards: [MemoryCard] = []
    @Published private(set) var timeRemaining: TimeInterval = MemoryGameConstants.gameDuration
    @Published private(set) var firstCardFlipped: MemoryCard? = nil
    @Published private(set) var secondCardFlipped: MemoryCard? = nil
    @Published var showingPauseMenu = false
    @Published private(set) var isProcessingPair = false
    @Published private(set) var disableCardInteraction = false
    
    // MARK: - Private Properties
    private var gameTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let onGameComplete: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(onGameComplete: ((Bool) -> Void)? = nil) {
        self.onGameComplete = onGameComplete
        setupNewGame()
    }
    
    // MARK: - Public Methods
    func setupNewGame() {
        // Generate cards
        cards = MemoryBoardConfiguration.generateCards()
        timeRemaining = MemoryGameConstants.gameDuration
        firstCardFlipped = nil
        secondCardFlipped = nil
        isProcessingPair = false
        disableCardInteraction = false
        gameState = .initial
        startGame()
    }
    
    func startGame() {
        startCountdown()
    }
    
    func resetGame() {
        cleanup()
        setupNewGame()
        showingPauseMenu = false
    }
    
    func pauseGame() {
        guard case .playing = gameState else { return }
        gameState = .paused
        gameTimer?.cancel()
    }
    
    func resumeGame() {
        guard case .paused = gameState else { return }
        gameState = .playing
        startGameTimer()
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
        gameTimer?.cancel()
        countdownTimer?.cancel()
    }
    
    func flipCard(at position: MemoryCard.Position) {
        // Немедленно блокируем взаимодействие, если пара уже обрабатывается
        guard !disableCardInteraction else { return }
        
        // Блокируем, если игра не в состоянии playing или если включено паузное меню
        guard case .playing = gameState, !showingPauseMenu else { return }
        
        // Если уже выбраны две карточки, не разрешаем дальнейшие нажатия
        if firstCardFlipped != nil && secondCardFlipped != nil {
            return
        }
        
        // Находим карточку по указанной позиции
        guard let cardIndex = cards.firstIndex(where: { $0.position == position }) else { return }
        let card = cards[cardIndex]
        
        // Разрешаем переворот только если карточка лежит рубашкой вниз
        guard card.state == .faceDown else { return }
        
        // Если это вторая карточка
        if let firstCard = firstCardFlipped {
            secondCardFlipped = card
            cards[cardIndex].state = .faceUp
            
            // Сразу блокируем дальнейшее взаимодействие, пока не обработаем пару
            disableCardInteraction = true
            
            // Проверяем совпадение
            if firstCard.imageIdentifier == card.imageIdentifier {
                handleMatch(first: firstCard, second: card)
            } else {
                handleNoMatch(first: firstCard, second: card)
            }
            
            HapticManager.shared.play(.light)
        }
        // Если это первая карточка
        else {
            firstCardFlipped = card
            cards[cardIndex].state = .faceUp
            
            HapticManager.shared.play(.light)
        }
    }
    
    // MARK: - Private Methods
    private func startCountdown() {
        var countdown = MemoryGameConstants.countdownDuration
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
        startGameTimer()
    }
    
    private func startGameTimer() {
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining <= 0.1 {
                    self.finishGame(success: false)
                } else {
                    self.timeRemaining -= 0.1
                }
            }
    }
    
    private func handleMatch(first: MemoryCard, second: MemoryCard) {
        // Use a short delay to allow the user to see the second card
        DispatchQueue.main.asyncAfter(deadline: .now() + MemoryGameConstants.animationDuration) { [weak self] in
            guard let self = self else { return }
            
            // Update card states to matched
            var updatedCards = self.cards
            
            // Update first card
            if let firstIndex = updatedCards.firstIndex(where: { $0.position == first.position }) {
                updatedCards[firstIndex].state = .matched
            }
            
            // Update second card
            if let secondIndex = updatedCards.firstIndex(where: { $0.position == second.position }) {
                updatedCards[secondIndex].state = .matched
            }
            
            self.cards = updatedCards
            
            // Reset the selection state
            self.firstCardFlipped = nil
            self.secondCardFlipped = nil
            self.disableCardInteraction = false
            
            // Play success haptic
            HapticManager.shared.play(.success)
            
            // Check if all cards are matched
            if self.allCardsMatched() {
                self.finishGame(success: true)
            }
        }
    }
    
    private func handleNoMatch(first: MemoryCard, second: MemoryCard) {
        // Use a delay to let the user see both cards
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Flip both cards back
            var updatedCards = self.cards
            
            // Update first card
            if let firstIndex = updatedCards.firstIndex(where: { $0.position == first.position }) {
                updatedCards[firstIndex].state = .faceDown
            }
            
            // Update second card
            if let secondIndex = updatedCards.firstIndex(where: { $0.position == second.position }) {
                updatedCards[secondIndex].state = .faceDown
            }
            
            self.cards = updatedCards
            
            // Reset the selection state
            self.firstCardFlipped = nil
            self.secondCardFlipped = nil
            self.disableCardInteraction = false
            
            // Play error haptic
            HapticManager.shared.play(.error)
        }
    }
    
    private func allCardsMatched() -> Bool {
        return cards.allSatisfy { card in
            card.state == .matched
        }
    }
    
    private func finishGame(success: Bool) {
        gameTimer?.cancel()
        HapticManager.shared.play(success ? .success : .error)
        gameState = .finished(success: success)
    }
}

// MARK: - Computed Properties
extension MemoryGameViewModel {
    var pairsMatched: Int {
        cards.filter { $0.state == .matched }.count / 2
    }
    
    var totalPairs: Int {
        MemoryGameConstants.pairsCount
    }
}
