
import SwiftUI

struct NavigationRootView: View {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var boardGameViewModel: BoardGameViewModel
    
    init() {
        let manager = NavigationManager()
        _navigationManager = StateObject(wrappedValue: manager)
        _boardGameViewModel = StateObject(wrappedValue: BoardGameViewModel(gameManager: manager.gameManager))
    }
    
    var body: some View {
        ZStack {
            switch navigationManager.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(navigationManager)
            case .gamesRoot:
                GamesRootView()
                    .environmentObject(navigationManager)
            case .boardGame:
                BoardGameView(viewModel: boardGameViewModel)
                    .environmentObject(navigationManager)
            case .waterGame:
                WaterGameView { success in
                    boardGameViewModel.handleResourceGameCompletion(success: success)
                    navigationManager.navigateBack()
                }
            case .woodGame:
                WoodGameView { success in
                    boardGameViewModel.handleResourceGameCompletion(success: success)
                    navigationManager.navigateBack()
                }
            case .foodGame(let viewModel):
                FoodGameView { success in
                    viewModel.handleResourceGameCompletion(success: success)
                    navigationManager.navigateBack()
                }
            case .memoryGame:
                MemoryGameView { success in
                    navigationManager.navigateBack()
                }
            case .game2048:
                Game2048View { success in
                    navigationManager.navigateBack()
                }
            case .ticTacToeGame:
                TicTacToeView { success in
                    navigationManager.navigateBack()
                }
            case .achievements:
                AchievementsView()
                    .environmentObject(navigationManager)
            case .tutorial:
                TutorialView()
                    .environmentObject(navigationManager)
            case .settings:
                SettingsView()
                    .environmentObject(navigationManager)
            }
        }
        .transition(.opacity)
        .onAppear {
            SoundManager.shared.updateMusicState()
        }
    }
}

#Preview {
    ContentView()
}
