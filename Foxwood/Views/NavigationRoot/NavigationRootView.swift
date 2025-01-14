//
//  NavigationRootView.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import SwiftUI

struct NavigationRootView: View {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        ZStack {
            switch navigationManager.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(navigationManager)
            case .boardGame:
                BoardGameView()
                    .environmentObject(navigationManager)
            case .waterGame:
                WaterGameView() // Заглушка, нужно реализовать
                    .environmentObject(navigationManager)
            case .woodGame:
                WoodGameView() // Заглушка, нужно реализовать
                    .environmentObject(navigationManager)
            case .foodGame:
                FoodGameView() // Заглушка, нужно реализовать
                    .environmentObject(navigationManager)
            case .achievements:
                AchievementsView() // Заглушка, нужно реализовать
                    .environmentObject(navigationManager)
            case .tutorial:
                TutorialView()
                    .environmentObject(navigationManager)
            case .settings:
                SettingsView() // Заглушка, нужно реализовать
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
