//
//  BoardGameCellView.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

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
                        Image(.emptyCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .web:
                        Image(.webCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .wood:
                        Image(.woodCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    case .water:
                        Image(.waterCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    case .mushroom:
                        Image(.mushroomCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    case .berries:
                        Image(.berriesCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(cell.isCompleted ? 0.5 : 1.0)
                            .scaleEffect(scale)
                    }
                } else {
                    Image(.greenCube)
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
