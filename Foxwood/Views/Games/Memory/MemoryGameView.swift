import SwiftUI

struct MemoryGameView: View {
    @StateObject private var viewModel: MemoryGameViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(onComplete: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: MemoryGameViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            // Game content
            switch viewModel.gameState {
            case .countdown(let count):
                CountdownView(count: count)
                
            case .playing, .paused, .initial:
                VStack {
                    // Timer
                    MemoryGameStatusBar(
                        menuAction: viewModel.togglePauseMenu,
                        timeRemaining: viewModel.timeRemaining
                    )
                    .padding(.top)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Game field
                    VStack(spacing: 2) {
                        ForEach(0..<MemoryBoardConfiguration.boardSize, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<MemoryBoardConfiguration.boardSize, id: \.self) { column in
                                    // Skip center cell
                                    if row == MemoryBoardConfiguration.boardSize / 2 &&
                                        column == MemoryBoardConfiguration.boardSize / 2 {
                                        Color.clear
                                            .aspectRatio(1, contentMode: .fit)
                                    } else {
                                        // Find card at this position
                                        if let card = viewModel.cards.first(where: {
                                            $0.position.row == row && $0.position.column == column
                                        }) {
                                            MemoryCardView(
                                                card: card,
                                                onTap: { viewModel.flipCard(at: card.position) },
                                                isInteractionDisabled: viewModel.disableCardInteraction
                                            )
                                        } else {
                                            Color.clear
                                                .aspectRatio(1, contentMode: .fit)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                    
                    Spacer()
                }
                
            case .finished(_):
                EmptyView()
            }
            
            // Pause menu
            if viewModel.showingPauseMenu {
                PauseMenuView(
                    onResume: { viewModel.togglePauseMenu() },
                    onExit: {
                        viewModel.cleanup()
                        navigationManager.navigateToMenu()
                    }
                )
            }
            
            // Game over screen
            if case .finished(let success) = viewModel.gameState {
                GameOverView(
                    success: success,
                    onExit: {
                        viewModel.completeGame()
                    }
                )
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Memory Game Status Bar
struct MemoryGameStatusBar: View {
    let menuAction: () -> Void
    let timeRemaining: TimeInterval
    
    var body: some View {
        HStack {
            MenuActionButton(image: .menuButton) {
                menuAction()
            }
            
            Spacer()
            
            ZStack {
                Image(.hexagon)
                    .resizable()
                    .frame(width: 130, height: 50)
                
                Text(String(format: "%.0f", timeRemaining))
                    .fontModifier(24)
                    .colorMultiply(timeRemaining < 10 ? .red : .white)
            }
        }
    }
}

#Preview {
    MemoryGameView { _ in }
        .environmentObject(NavigationManager())
}
