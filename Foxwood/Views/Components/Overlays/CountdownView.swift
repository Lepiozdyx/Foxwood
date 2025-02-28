
import SwiftUI

struct CountdownView: View {
    @State private var isAnimating = false
    let count: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            Text("Get Ready!")
                .fontModifier(30)
                .scaleEffect(isAnimating ? 1.1 : 0.95)
                .animation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .ignoresSafeArea()
        .onAppear {
            isAnimating.toggle()
        }
    }
}

#Preview {
    CountdownView(count: 3)
}
