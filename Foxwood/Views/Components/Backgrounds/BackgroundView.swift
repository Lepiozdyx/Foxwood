
import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Image(.bg)
            .resizable()
            .ignoresSafeArea()
            .blur(radius: 6)
    }
}

#Preview {
    BackgroundView()
}
