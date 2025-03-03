
import SwiftUI

struct BoardGameView: View {
    @ObservedObject var viewModel: BoardGameViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                BackgroundView(name: .backgrClassic)
                
                // MARK: Game field
                VStack {
                    Spacer()
                    
                    VStack(spacing: 2) {
                        ForEach(0..<BoardConfiguration.boardSize, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<BoardConfiguration.boardSize, id: \.self) { column in
                                    let cell = viewModel.cells[row][column]
                                    
                                    BoardGameCellView(
                                        cell: cell,
                                        onReveal: {
                                            handleCellReveal(row: row, column: column)
                                        },
                                        onResourceTap: { cellType in
                                            handleResourceTap(cellType)
                                        },
                                        isBlocked: viewModel.isResourcePending
                                    )
                                    
                                }
                            }
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(50)
                    .background(
                        BoardView(width: width, height: height)
                            .overlay(alignment: .top) {
                                MovesCounterView(movesLeft: viewModel.movesLeft)
                            }
                    )
                    
                    Spacer()
                }
                .padding()
                
                // MARK: TopBar
                GameTopBarView(
                    woodCount: viewModel.woodCount,
                    waterCount: viewModel.waterCount,
                    foodCount: viewModel.foodCount
                ) {
                    viewModel.togglePauseMenu()
                }
                
                // MARK: PauseMenu
                if viewModel.showingPauseMenu {
                    PauseMenuView(
                        onResume: { viewModel.togglePauseMenu() },
                        onExit: {
                            viewModel.resetGame()
                            navigationManager.navigateToMenu()
                        }
                    )
                }
                
                // MARK: EndGameView
                if viewModel.isGameOver {
                    EndGameView(
                        result: viewModel.hasWon,
                        onExit: {
                            viewModel.resetGame()
                            navigationManager.navigateToMenu()
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - actions
    private func handleCellReveal(row: Int, column: Int) {
        let position = Cell.Position(row: row, column: column)
        _ = viewModel.revealCell(at: position)
    }
    
    private func handleResourceTap(_ cellType: CellType) {
        switch cellType {
        case .wood:
            navigationManager.navigate(to: .woodGame)
        case .water:
            navigationManager.navigate(to: .waterGame)
        case .mushroom, .berries:
            navigationManager.navigate(to: .foodGame(viewModel))
        default:
            break
        }
    }
}

// MARK: - GameTopBarView
struct GameTopBarView: View {
    let woodCount: Int
    let waterCount: Int
    let foodCount: Int
    let onMenuTap: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                MenuActionButton(image: .menuButton, action: onMenuTap)
                
                Spacer()
                
                ResourceCounterView(
                    woodCount: woodCount,
                    waterCount: waterCount,
                    foodCount: foodCount
                )
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - MovesCounterView
struct MovesCounterView: View {
    let movesLeft: Int
    
    var body: some View {
        ZStack {
            Image(.hexagon)
                .resizable()
                .frame(width: 150, height: 50)
            
            Text("Step \(movesLeft)/10")
                .fontModifier(18)
                .shadow(color: .black, radius: 1)
        }
        .offset(y: -15)
    }
}

// MARK: - ResourceCounterView
struct ResourceCounterView: View {
    let woodCount: Int
    let waterCount: Int
    let foodCount: Int
    
    var body: some View {
        Image(.greenUnd)
            .resizable()
            .frame(width: 130, height: 110)
            .shadow(color: .black, radius: 4, x: -2, y: 2)
            .overlay {
                VStack(spacing: 4) {
                    Text("Collection rate")
                        .fontModifier(12)
                    VStack(spacing: 4) {
                        Text("wood - \(woodCount)/2")
                            .fontModifier(14)
                        Text("water - \(waterCount)/2")
                            .fontModifier(14)
                        Text("food - \(foodCount)/2")
                            .fontModifier(14)
                    }
                }
                .shadow(color: .black, radius: 1)
                .offset(y: -5)
            }
    }
}

#Preview {
    BoardGameView(viewModel: BoardGameViewModel())
        .environmentObject(NavigationManager())
}
