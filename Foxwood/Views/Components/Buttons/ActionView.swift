
import SwiftUI

struct ActionView: View {
    let text: String
    let fontSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Image(.mainActionButton)
            .resizable()
            .frame(maxWidth: width, maxHeight: height)
            .overlay {
                Text(text)
                    .fontModifier(fontSize)
                    .padding()
                    .offset(y: -3)
            }
            .playSound()
    }
}

#Preview {
    ZStack {
        BackgroundView()
        ActionView(text: "next", fontSize: 30, width: 280, height: 100)
    }
}
