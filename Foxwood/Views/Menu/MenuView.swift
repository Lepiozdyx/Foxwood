
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
                        ActionView(text: "Play", fontSize: 20, width: 300, height: 100)
                    }
                    
                    //AchievementsView
                    Button {
                        navigationManager.navigate(to: .achievements)
                    } label: {
                        ActionView(text: "Achievements", fontSize: 20, width: 300, height: 100)
                    }
                }
                
                HStack(spacing: 20) {
                    //SettingsView
                    Button {
                        navigationManager.navigate(to: .settings)
                    } label: {
                        ActionView(text: "Settings", fontSize: 20, width: 300, height: 100)
                    }
                    
                    //TutorialView
                    Button {
                        navigationManager.navigate(to: .tutorial)
                    } label: {
                        ActionView(text: "How to play", fontSize: 20, width: 300, height: 100)
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
