
import SwiftUI

extension Text {
    func fontModifier(_ size: CGFloat) -> some View {
        self
            .foregroundStyle(.white)
            .font(.system(size: size, weight: .regular, design: .serif))
            .shadow(color: .black, radius: 1, x: 1, y: 1)
            .textCase(.uppercase)
            .multilineTextAlignment(.center)
    }
}

struct Ext_Text: View {
    var body: some View {
        Text("foxwood")
            .fontModifier(40)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        Ext_Text()
    }
}
