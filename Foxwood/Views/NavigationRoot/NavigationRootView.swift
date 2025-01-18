//
//  NavigationRootView.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

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
            case .foodGame:
                FoodGameView { success in
                    boardGameViewModel.handleResourceGameCompletion(success: success)
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
