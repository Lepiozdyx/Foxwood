
import SwiftUI

struct MenuActionButton: View {
    let image: ImageResource
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(image)
                .resizable()
                .frame(width: 45, height: 45)
        }
        .playSound()
    }
}

#Preview {
    MenuActionButton(image: .menuButton, action: {})
}
