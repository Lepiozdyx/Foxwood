
import SwiftUI

struct Game2048View: View {
    @StateObject private var viewModel: Game2048ViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(onComplete: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: Game2048ViewModel(onGameComplete: onComplete))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundView()
                
                // Game content
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
                        
                        // Game board container
                        Game2048BoardView(
                            tiles: viewModel.tiles,
                            boardSize: Game2048Constants.boardSize,
                            boardWidth: min(geo.size.width - 60, geo.size.height / 1.8 - 40)
                        )
                        .padding()
                        .gesture(
                            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                .onEnded { value in
                                    let horizontalAmount = value.translation.width
                                    let verticalAmount = value.translation.height
                                    
                                    if abs(horizontalAmount) > abs(verticalAmount) {
                                        if horizontalAmount > 0 {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                viewModel.move(.right)
                                            }
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                viewModel.move(.left)
                                            }
                                        }
                                    } else {
                                        if verticalAmount > 0 {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                viewModel.move(.down)
                                            }
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                viewModel.move(.up)
                                            }
                                        }
                                    }
                                }
                        )
                        
                        Spacer()
                    }
                    
                case .finished(_):
                    EmptyView()
                }
                
                // Pause menu
                if viewModel.showingPauseMenu {
                    PauseMenuView(
                        onResume: { viewModel.togglePauseMenu() },
                        onExit: {
                            viewModel.cleanup()
                            navigationManager.navigateToMenu()
                        }
                    )
                }
                
                // Game over screen
                if case .finished(let success) = viewModel.gameState {
                    GameOverView(
                        success: success,
                        onExit: {
                            viewModel.completeGame()
                        }
                    )
                }
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
        HStack {
            MenuActionButton(image: .menuButton, action: onMenuTap)
            
            Spacer()
            
            ZStack {
                Image(.hexagon)
                    .resizable()
                    .frame(width: 120, height: 50)
                
                Text("\(score)")
                    .fontModifier(20)
                    .animation(.easeInOut, value: score)
            }
        }
    }
}

// MARK: - Game Board View
struct Game2048BoardView: View {
    let tiles: [Tile]
    let boardSize: Int
    let boardWidth: CGFloat
    
    private var cellWidth: CGFloat {
        (boardWidth - CGFloat(boardSize - 1) * Game2048Constants.tileSpacing) / CGFloat(boardSize)
    }
    
    var body: some View {
        ZStack {
            BoardView(width: boardWidth, height: boardWidth)
            
            BoardGridView(
                tiles: tiles,
                boardSize: boardSize,
                cellWidth: cellWidth,
                spacing: Game2048Constants.tileSpacing
            )
            .padding(Game2048Constants.tileSpacing)
        }
        .frame(width: boardWidth, height: boardWidth)
    }
}

// MARK: - Board Grid View (iOS 15 compatible)
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
                let tile = tiles.first {
                    $0.position.row == position.row &&
                    $0.position.column == position.column
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: cellWidth, height: cellWidth)
                    
                    if let tile = tile {
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
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(tile.color)
                .frame(width: width, height: width)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            
            Text("\(tile.value)")
                .font(.system(size: width * 0.4, weight: .bold, design: .rounded))
                .foregroundStyle(tile.textColor)
                .animation(.easeInOut(duration: 0.15), value: tile.value)
        }
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
