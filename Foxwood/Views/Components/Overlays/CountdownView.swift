
import SwiftUI

struct CountdownView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            VStack {
                Text("Get Ready!")
                    .fontModifier(30)
                Text("\(count)")
                    .fontModifier(40)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CountdownView(count: 3)
}
