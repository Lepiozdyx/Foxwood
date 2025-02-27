
import SwiftUI

struct TicTacToeView: View {
    @StateObject private var viewModel: TicTacToeViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(onComplete: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: TicTacToeViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            switch viewModel.gameState {
            case .playing, .paused, .initial:
                VStack {
                    TicTacToeHeaderView(
                        currentPlayer: viewModel.currentPlayer,
                        onMenuTap: viewModel.togglePauseMenu
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    // Game Board
                    TicTacToeBoardView(
                        cells: viewModel.cells,
                        boardSize: TicTacToeConstants.boardSize,
                        onCellTap: { position in
                            viewModel.makeMove(at: position)
                        }
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                    
                    Spacer()
                }
                
            case .finished(_):
                EmptyView()
            }
            
            if viewModel.showingPauseMenu {
                PauseMenuView(
                    onResume: { viewModel.togglePauseMenu() },
                    onExit: {
                        navigationManager.navigateToMenu()
                    }
                )
            }
            
            if case .finished(let winner) = viewModel.gameState {
                TicTacToeGameOverView(
                    winner: winner,
                    onExit: { viewModel.completeGame() }
                )
            }
        }
    }
}

// MARK: - Header View
struct TicTacToeHeaderView: View {
    let currentPlayer: Player
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            MenuActionButton(image: .menuButton, action: onMenuTap)
            
            Spacer()
            
            ZStack {
                Image(.hexagon)
                    .resizable()
                    .frame(width: 190, height: 60)
                
                HStack(spacing: 8) {
                    Image(currentPlayer.imageName)
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text(currentPlayer.displayName)
                        .fontModifier(20)
                }
            }
        }
    }
}

// MARK: - Board View
struct TicTacToeBoardView: View {
    let cells: [TicTacCell]
    let boardSize: Int
    let onCellTap: (TicTacCell.Position) -> Void

    var body: some View {
        GeometryReader { geo in
            let boardWidth = geo.size.width
            let cellWidth = (boardWidth - CGFloat(boardSize - 1) * 8) / CGFloat(boardSize)
            
            TicTacToeBoardGridView(
                cells: cells,
                boardSize: boardSize,
                cellWidth: cellWidth,
                spacing: 4,
                onCellTap: onCellTap
            )
        }
    }
}

// MARK: - Board Grid View
struct TicTacToeBoardGridView: View {
    let cells: [TicTacCell]
    let boardSize: Int
    let cellWidth: CGFloat
    let spacing: CGFloat
    let onCellTap: (TicTacCell.Position) -> Void

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<boardSize, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<boardSize, id: \.self) { column in
                        let position = TicTacCell.Position(row: row, column: column)
                        let cell = cells.first(where: { $0.position == position }) ??
                                   TicTacCell(position: position)
                        
                        TicTacToeCellView(
                            cell: cell,
                            width: cellWidth,
                            onTap: {
                                onCellTap(position)
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Cell View
struct TicTacToeCellView: View {
    let cell: TicTacCell
    let width: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.3))
                    .frame(width: width, height: width)
                
                if let player = cell.player {
                    Image(player.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.95)
                }
            }
        }
        .buttonStyle(.plain)
        .playSound()
    }
}

// MARK: - Game Over View
struct TicTacToeGameOverView: View {
    let winner: Player?
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            BoardView(width: 400, height: 350)
                .overlay(alignment: .top) {
                    ZStack {
                        Image(.hexagon)
                            .resizable()
                            .frame(width: 150, height: 50)
                        
                        Text(winner != nil ? "Winner!" : "Draw!")
                            .fontModifier(18)
                    }
                }
                .overlay {
                    VStack(spacing: 20) {
                        if let winner = winner {
                            HStack(spacing: 8) {
                                Image(winner.imageName)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                
                                Text("\(winner.displayName) wins!")
                                    .fontModifier(24)
                            }
                        } else {
                            Text("It's a draw!")
                                .fontModifier(24)
                        }
                        
                        Button {
                            onExit()
                        } label: {
                            ActionView(
                                text: "Back",
                                fontSize: 24,
                                width: 250,
                                height: 70
                            )
                        }
                    }
                }
                .padding()
        }
    }
}

#Preview {
    TicTacToeView { _ in }
        .environmentObject(NavigationManager())
}
