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
    case foodGame(BoardGameViewModel)
    case achievements
    case tutorial
    case settings
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.menu, .menu),
             (.boardGame, .boardGame),
             (.waterGame, .waterGame),
             (.woodGame, .woodGame),
             (.achievements, .achievements),
             (.tutorial, .tutorial),
             (.settings, .settings):
            return true
        case (.foodGame(let lvm), .foodGame(let rvm)):
            return lvm === rvm
        default:
            return false
        }
    }
}

final class NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .menu
    @Published var navigationStack: [Screen] = []
    
    // Добавляем GameManager как свойство NavigationManager
    let gameManager = GameManager()
    
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
            // Сбрасываем состояние игры только при возврате в меню
            gameManager.resetGame()
        }
    }
}
