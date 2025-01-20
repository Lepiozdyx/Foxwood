
import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(.logo)
                .resizable()
                .frame(width: 150, height: 150)
                .scaleEffect(isAnimating ? 1.1 : 0.99)
                .animation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Spacer()
        }
        .onAppear {
            isAnimating.toggle()
        }
    }
}

#Preview {
    LoadingView()
}
