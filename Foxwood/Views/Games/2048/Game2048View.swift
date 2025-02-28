
import SwiftUI

struct Game2048View: View {
    @StateObject private var viewModel: Game2048ViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(onComplete: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: Game2048ViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        ZStack {
            BackgroundView(name: .bg2048)
            
            switch viewModel.gameState {
            case .playing, .paused, .initial:
                VStack {
                    Game2048HeaderView(
                        score: viewModel.score,
                        onMenuTap: viewModel.togglePauseMenu
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    Game2048BoardView(
                        tiles: viewModel.tiles,
                        boardSize: Game2048Constants.boardSize
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 20, coordinateSpace: .local)
                            .onEnded { value in
                                let horizontalAmount = value.translation.width
                                let verticalAmount = value.translation.height
                                
                                if abs(horizontalAmount) > abs(verticalAmount) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        horizontalAmount > 0 ? viewModel.move(.right) : viewModel.move(.left)
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        verticalAmount > 0 ? viewModel.move(.down) : viewModel.move(.up)
                                    }
                                }
                            }
                    )
                    
                    Spacer()
                }
                
            case .finished(_):
                EmptyView()
            }
            
            if viewModel.showingPauseMenu {
                PauseMenuView(
                    onResume: { viewModel.togglePauseMenu() },
                    onExit: {
                        viewModel.cleanup()
                        navigationManager.navigateToMenu()
                    }
                )
            }
            
            if case .finished(let success) = viewModel.gameState {
                GameOverView(
                    success: success,
                    onExit: { viewModel.completeGame() }
                )
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Game2048 Header View
struct Game2048HeaderView: View {
    let score: Int
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            MenuActionButton(image: .menuButton, action: onMenuTap)
            
            Spacer()
            
            ZStack {
                Image(.hexagon)
                    .resizable()
                    .frame(width: 120, height: 50)
                
                Text("\(score)")
                    .fontModifier(20)
            }
        }
    }
}

// MARK: - Game Board View
struct Game2048BoardView: View {
    let tiles: [Tile]
    let boardSize: Int

    var body: some View {
        GeometryReader { geo in
            let boardWidth = geo.size.width
            let cellWidth = (boardWidth - CGFloat(boardSize - 1) * Game2048Constants.tileSpacing) / CGFloat(boardSize)
            BoardGridView(
                tiles: tiles,
                boardSize: boardSize,
                cellWidth: cellWidth,
                spacing: Game2048Constants.tileSpacing
            )
        }
    }
}

// MARK: - Board Grid View
struct BoardGridView: View {
    let tiles: [Tile]
    let boardSize: Int
    let cellWidth: CGFloat
    let spacing: CGFloat

    var body: some View {
        let positions = (0..<boardSize).flatMap { row in
            (0..<boardSize).map { column in
                GridPosition(row: row, column: column)
            }
        }
        let columns = Array(
            repeating: GridItem(.fixed(cellWidth), spacing: spacing),
            count: boardSize
        )
        
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(positions) { position in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.black.opacity(0.6))
                        .frame(width: cellWidth, height: cellWidth)
                    
                    if let tile = tiles.first(where: {
                        $0.position.row == position.row &&
                        $0.position.column == position.column
                    }) {
                        TileView(tile: tile, width: cellWidth * 0.95)
                            .id(tile.id)
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.2), value: tile.position)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tile.value)
                    }
                }
                .frame(width: cellWidth, height: cellWidth)
            }
        }
    }
    
    struct GridPosition: Identifiable {
        let id = UUID()
        let row: Int
        let column: Int
    }
}

// MARK: - Tile View
struct TileView: View {
    let tile: Tile
    let width: CGFloat
    
    @State private var isAppearing = false
    
    var body: some View {
        Image(tile.tileImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
            .scaleEffect(isAppearing ? 1.0 : (tile.isNew ? 0.5 : 1.0))
            .opacity(isAppearing ? 1.0 : (tile.isNew ? 0.0 : 1.0))
            .onAppear {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    isAppearing = true
                }
            }
    }
}

#Preview {
    Game2048View { _ in }
        .environmentObject(NavigationManager())
}
