
import SwiftUI

struct BoardGameCellView: View {
    @State private var scale: CGFloat = 1.0
    
    let cell: Cell
    let onReveal: () -> Void
    let onResourceTap: ((CellType) -> Void)?
    let isBlocked: Bool
    
    var body: some View {
        Button {
            if !cell.isRevealed {
                onReveal()
            } else if cell.type.isResource && !cell.isCompleted {
                onResourceTap?(cell.type)
            }
        } label: {
            ZStack {
                if cell.isRevealed {
                    switch cell.type {
                    case .empty:
                        Image(.emptyQ)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .web:
                        Image(.spiderQ)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .wood:
                        Image(.woodQ)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    case .water:
                        Image(.waterQ)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    case .mushroom:
                        Image(.mushroomQ)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    case .berries:
                        Image(.berriesQ)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    }
                } else {
                    Image(.greenQ)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(minWidth: 50, minHeight: 50)
        }
        .disabled(
            (cell.isRevealed && (!cell.type.isResource || cell.isCompleted)) ||
            (!cell.isRevealed && isBlocked)
        )
        .playSound()
        .onChange(of: cell.isRevealed) { newValue in
            if newValue && cell.type.isResource && !cell.isCompleted {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 0.9
                }
            }
        }
        .onChange(of: cell.isCompleted) { completed in
            if completed {
                withAnimation {
                    scale = 1.0
                }
            }
        }
    }
}

#Preview {
    BoardGameCellView(
        cell: Cell(position: .init(row: 0, column: 0), type: .wood, isRevealed: true),
        onReveal: {},
        onResourceTap: { _ in },
        isBlocked: true
    )
}
