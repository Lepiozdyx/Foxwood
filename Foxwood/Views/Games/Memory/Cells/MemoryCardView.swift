
import SwiftUI

struct MemoryCardView: View {
    let card: MemoryCard
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var flipped: Bool = false
    
    var body: some View {
        Button {
            if card.state == .faceDown {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation += 180
                    flipped = true
                }
                onTap()
            }
        } label: {
            ZStack {
                // Card back (when face down)
                Image(.greenCube)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(flipped ? 0 : 1)
                
                // Card front (when face up)
                ZStack {
                    Image(.emptyCube)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Image(systemName: "\(card.imageIdentifier).circle")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
                .opacity(flipped ? 1 : 0)
            }
            .frame(minWidth: 50, minHeight: 50)
            .scaleEffect(scale)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .buttonStyle(.plain)
        .disabled(card.state == .matched)
        .playSound()
        .onChange(of: card.state) { newState in
            switch newState {
            case .faceDown:
                if flipped {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        rotation += 180
                        flipped = false
                    }
                }
            case .faceUp:
                if !flipped {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        rotation += 180
                        flipped = true
                    }
                }
            case .matched:
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 0.9
                }
            }
        }
    }
}

#Preview {
    VStack {
        MemoryCardView(
            card: MemoryCard(imageIdentifier: 1, position: .init(row: 0, column: 0)),
            onTap: {}
        )
        
        MemoryCardView(
            card: MemoryCard(imageIdentifier: 2, state: .faceUp, position: .init(row: 0, column: 1)),
            onTap: {}
        )
        
        MemoryCardView(
            card: MemoryCard(imageIdentifier: 3, state: .matched, position: .init(row: 0, column: 2)),
            onTap: {}
        )
    }
}
