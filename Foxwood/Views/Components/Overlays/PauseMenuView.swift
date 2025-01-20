
import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .overlay {
                ZStack {
                    BoardView(width: 400, height: 350)
                        .overlay(alignment: .top) {
                            Image(.hexagon)
                                .resizable()
                                .frame(width: 170, height: 70)
                            Text("PAUSE")
                                .fontModifier(16)
                        }
                    
                    VStack(spacing: 20) {
                        Button {
                            onResume()
                        } label: {
                            ActionView(
                                text: "RESUME",
                                fontSize: 28,
                                width: 250,
                                height: 70
                            )
                        }
                        
                        Button {
                            onExit()
                        } label: {
                            ActionView(
                                text: "MENU",
                                fontSize: 28,
                                width: 250,
                                height: 70
                            )
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
    }
}

#Preview {
    PauseMenuView(onResume: {}, onExit: {})
}
