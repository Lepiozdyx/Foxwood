
import SwiftUI

struct EndGameView: View {
    let result: Bool
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            if result {
                Color.yellow.opacity(0.5)
                    .ignoresSafeArea()
            } else {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
            }
            
            BoardView(width: 400, height: 350)
                .overlay(alignment: .top) {
                    ZStack {
                        Image(.hexagon)
                            .resizable()
                            .frame(width: 150, height: 50)
                        
                        Text(result ?
                             "Win" :
                             "Game over"
                        )
                        .fontModifier(18)
                    }
                }
                .overlay {
                    VStack(spacing: 20) {
                        Text(result ?
                             "Congratulations! \nYou've gathered the resources you need to spend a night in the Foxwood forest!" :
                             "Unfortunately, you didn't get enough resources. \nYou'll get them next time!"
                        )
                        .fontModifier(22)
                        .padding(.horizontal, 40)
                        
                        Button {
                            onExit()
                        } label: {
                            ActionView(
                                text: "Menu",
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
    EndGameView(result: false, onExit: {})
}
