
import SwiftUI

struct BackgroundView: View {
    var name: ImageResource = .backgr
    
    var body: some View {
        Image(name)
            .resizable()
            .ignoresSafeArea()
            .blur(radius: 2, opaque: true)
    }
}

#Preview {
    BackgroundView()
}
