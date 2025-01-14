//
//  MenuView.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    //BoardGameView
                    Button {
                        navigationManager.navigate(to: .boardGame)
                    } label: {
                        ActionView(text: "Play", fontSize: 26, width: 320, height: 110)
                    }
                    
                    //AchievementsView
                    Button {
                        navigationManager.navigate(to: .achievements)
                    } label: {
                        ActionView(text: "Achievements", fontSize: 26, width: 320, height: 110)
                    }
                }
                
                HStack(spacing: 20) {
                    //SettingsView
                    Button {
                        navigationManager.navigate(to: .settings)
                    } label: {
                        ActionView(text: "Settings", fontSize: 26, width: 320, height: 110)
                    }
                    
                    //TutorialView
                    Button {
                        navigationManager.navigate(to: .tutorial)
                    } label: {
                        ActionView(text: "How to play", fontSize: 26, width: 320, height: 110)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(NavigationManager())
}
