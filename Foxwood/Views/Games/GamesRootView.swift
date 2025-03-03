
import SwiftUI

struct GamesRootView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack {
                    MenuActionButton(image: .returnButton) {
                        navigationManager.navigateBack()
                    }
                    Spacer()
                    
                    MenuActionButton(image: .circleButton) {
                        navigationManager.navigate(to: .settings)
                    }
                }
                Spacer()
            }
            .padding()
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button {
                        navigationManager.navigate(to: .boardGame)
                    } label: {
                        Image(.classicGame)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                    }
                    .playSound()
                    
                    Button {
                        navigationManager.navigate(to: .memoryGame)
                    } label: {
                        Image(.memory)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                    }
                    .playSound()
                }
                
                HStack(spacing: 20) {
                    Button {
                        navigationManager.navigate(to: .game2048)
                    } label: {
                        Image(._2048Button)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                    }
                    .playSound()
                    
                    Button {
                        navigationManager.navigate(to: .ticTacToeGame)
                    } label: {
                        Image(.ttt)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                    }
                    .playSound()
                }
            }
            .padding()
        }
    }
}

#Preview {
    GamesRootView()
        .environmentObject(NavigationManager())
}
