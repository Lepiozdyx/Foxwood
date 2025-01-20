
import SwiftUI

struct GameOverView: View {
    let success: Bool
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            BoardView(width: 400, height: 350)
                .overlay(alignment: .top) {
                    ZStack {
                        Image(.hexagon)
                            .resizable()
                            .frame(width: 130, height: 50)
                        
                        Text(success ?
                             "Win" :
                             "Loose"
                        )
                        .fontModifier(18)
                    }
                }
                .overlay {
                    VStack(spacing: 20) {
                        Text(success ?
                             "All right! You did it!" :
                             "You didn't get enough resources"
                        )
                        .fontModifier(24)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        
                        Button {
                            onExit()
                        } label: {
                            ActionView(
                                text: "Back to board",
                                fontSize: 24,
                                width: 250,
                                height: 70
                            )
                        }
                    }
                }
                .padding()
        }
    }
}

#Preview {
    GameOverView(success: true, onExit: {})
}

