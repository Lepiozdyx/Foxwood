//
//  NavigationManager.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import SwiftUI

enum Screen: Equatable {
    case menu
    case boardGame
    case waterGame
    case woodGame
    case foodGame
    case achievements
    case tutorial
    case settings
}

final class NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .menu
    @Published var navigationStack: [Screen] = []
    
    func navigate(to screen: Screen) {
        withAnimation {
            navigationStack.append(currentScreen)
            currentScreen = screen
        }
    }
    
    func navigateBack() {
        guard let previousScreen = navigationStack.popLast() else { return }
        
        withAnimation {
            currentScreen = previousScreen
        }
    }
    
    func navigateToMenu() {
        withAnimation {
            currentScreen = .menu
            navigationStack.removeAll()
        }
    }
    
//    private func playSound() {
//        SoundManager.shared.playSound()
//    }
}
