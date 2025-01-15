//
//  BoardGameCellView.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import SwiftUI

struct BoardGameCellView: View {
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
                    case .water:
                        Image(.waterCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .mushroom:
                        Image(.mushroomCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .berries:
                        Image(.berriesCube)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
