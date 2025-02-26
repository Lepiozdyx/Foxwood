
import SwiftUI

enum Game2048Constants {
    static let boardSize = 4
    static let winValue = 2048
    static let initialTileCount = 2
    static let animationDuration: TimeInterval = 0.2
    static let tileSize: CGFloat = 72
    static let tileSpacing: CGFloat = 8
}

enum MoveDirection {
    case up, down, left, right
}

enum Game2048State: Equatable {
    case initial
    case playing
    case paused
    case finished(success: Bool)
}

struct Tile: Identifiable, Equatable {
    let id = UUID()
    var value: Int
    var position: Position
    var isNew: Bool = true
    var isMerged: Bool = false
    var mergedFromIDs: (UUID, UUID)? = nil
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    // Get the appropriate color based on tile value
    var color: Color {
        switch value {
        case 2: return Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4: return Color(red: 0.93, green: 0.87, blue: 0.78)
        case 8: return Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16: return Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32: return Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64: return Color(red: 0.96, green: 0.37, blue: 0.24)
        case 128: return Color(red: 0.93, green: 0.81, blue: 0.45)
        case 256: return Color(red: 0.93, green: 0.80, blue: 0.38)
        case 512: return Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: return Color(red: 0.93, green: 0.77, blue: 0.25)
        case 2048: return Color(red: 0.93, green: 0.76, blue: 0.18)
        default: return Color(red: 0.80, green: 0.94, blue: 0.95)
        }
    }
    
    // Get text color based on tile value
    var textColor: Color {
        value <= 4 ? .black : .white
    }
    
    // Reset merge state
    mutating func resetMergeState() {
        isNew = false
        isMerged = false
        mergedFromIDs = nil
    }
    
    // Implement Equatable
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        lhs.id == rhs.id &&
        lhs.value == rhs.value &&
        lhs.position == rhs.position &&
        lhs.isNew == rhs.isNew &&
        lhs.isMerged == rhs.isMerged
    }
}

struct Game2048 {
    var board: [[Tile?]]
    var score: Int = 0
    var bestScore: Int = 0
    var movesCount: Int = 0
    var hasWon: Bool = false
    var isGameOver: Bool = false
    
    init() {
        // Initialize empty board
        board = Array(repeating: Array(repeating: nil, count: Game2048Constants.boardSize), count: Game2048Constants.boardSize)
        
        // Add initial tiles
        for _ in 0..<Game2048Constants.initialTileCount {
            addRandomTile()
        }
    }
    
    // MARK: - Game Logic
    
    // Add a random tile to the board
    mutating func addRandomTile() {
        // Get all empty cells
        var emptyCells: [Tile.Position] = []
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if board[row][column] == nil {
                    emptyCells.append(Tile.Position(row: row, column: column))
                }
            }
        }
        
        // If there are no empty cells, return
        if emptyCells.isEmpty {
            return
        }
        
        // Choose a random empty cell
        let randomPosition = emptyCells.randomElement()!
        
        // Create a new tile
        let value = Double.random(in: 0...1) < 0.9 ? 2 : 4
        let newTile = Tile(value: value, position: randomPosition, isNew: true)
        
        // Place the tile on the board
        board[randomPosition.row][randomPosition.column] = newTile
    }
    
    // Check if the game is over
    mutating func checkGameOver() {
        // Check if there are any empty cells
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if board[row][column] == nil {
                    return
                }
            }
        }
        
        // Check if there are any adjacent cells with the same value
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if let tile = board[row][column] {
                    // Check right
                    if column < Game2048Constants.boardSize - 1,
                       let rightTile = board[row][column + 1],
                       rightTile.value == tile.value {
                        return
                    }
                    
                    // Check down
                    if row < Game2048Constants.boardSize - 1,
                       let downTile = board[row + 1][column],
                       downTile.value == tile.value {
                        return
                    }
                }
            }
        }
        
        // If we got here, the game is over
        isGameOver = true
    }
    
    // Perform a move in the specified direction
    mutating func move(_ direction: MoveDirection) -> Bool {
        // Reset merge state for all tiles
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if var tile = board[row][column] {
                    tile.resetMergeState()
                    board[row][column] = tile
                }
            }
        }
        
        var moved = false
        
        switch direction {
        case .up:
            moved = moveUp()
        case .down:
            moved = moveDown()
        case .left:
            moved = moveLeft()
        case .right:
            moved = moveRight()
        }
        
        // If the board changed, add a new tile
        if moved {
            addRandomTile()
            movesCount += 1
        }
        
        // Check if the game is over
        checkGameOver()
        
        return moved
    }
    
    private mutating func moveUp() -> Bool {
        var moved = false
        
        for column in 0..<Game2048Constants.boardSize {
            for row in 1..<Game2048Constants.boardSize {
                if let tile = board[row][column] {
                    var currentRow = row
                    
                    // Move the tile up as far as possible
                    while currentRow > 0 && board[currentRow - 1][column] == nil {
                        board[currentRow - 1][column] = Tile(
                            value: tile.value,
                            position: Tile.Position(row: currentRow - 1, column: column),
                            isNew: false
                        )
                        board[currentRow][column] = nil
                        currentRow -= 1
                        moved = true
                    }
                    
                    // Check if we can merge with the tile above
                    if currentRow > 0,
                       let aboveTile = board[currentRow - 1][column],
                       aboveTile.value == tile.value,
                       !aboveTile.isMerged {
                        
                        // Merge the tiles
                        let mergedValue = tile.value * 2
                        board[currentRow - 1][column] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: currentRow - 1, column: column),
                            isNew: false,
                            isMerged: true,
                            mergedFromIDs: (aboveTile.id, tile.id)
                        )
                        board[currentRow][column] = nil
                        
                        // Update score
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
                        // Check for win
                        if mergedValue >= Game2048Constants.winValue {
                            hasWon = true
                        }
                        
                        moved = true
                    }
                }
            }
        }
        
        return moved
    }
    
    private mutating func moveDown() -> Bool {
        var moved = false
        
        for column in 0..<Game2048Constants.boardSize {
            for row in (0..<Game2048Constants.boardSize - 1).reversed() {
                if let tile = board[row][column] {
                    var currentRow = row
                    
                    // Move the tile down as far as possible
                    while currentRow < Game2048Constants.boardSize - 1 && board[currentRow + 1][column] == nil {
                        board[currentRow + 1][column] = Tile(
                            value: tile.value,
                            position: Tile.Position(row: currentRow + 1, column: column),
                            isNew: false
                        )
                        board[currentRow][column] = nil
                        currentRow += 1
                        moved = true
                    }
                    
                    // Check if we can merge with the tile below
                    if currentRow < Game2048Constants.boardSize - 1,
                       let belowTile = board[currentRow + 1][column],
                       belowTile.value == tile.value,
                       !belowTile.isMerged {
                        
                        // Merge the tiles
                        let mergedValue = tile.value * 2
                        board[currentRow + 1][column] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: currentRow + 1, column: column),
                            isNew: false,
                            isMerged: true,
                            mergedFromIDs: (belowTile.id, tile.id)
                        )
                        board[currentRow][column] = nil
                        
                        // Update score
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
                        // Check for win
                        if mergedValue >= Game2048Constants.winValue {
                            hasWon = true
                        }
                        
                        moved = true
                    }
                }
            }
        }
        
        return moved
    }
    
    private mutating func moveLeft() -> Bool {
        var moved = false
        
        for row in 0..<Game2048Constants.boardSize {
            for column in 1..<Game2048Constants.boardSize {
                if let tile = board[row][column] {
                    var currentColumn = column
                    
                    // Move the tile left as far as possible
                    while currentColumn > 0 && board[row][currentColumn - 1] == nil {
                        board[row][currentColumn - 1] = Tile(
                            value: tile.value,
                            position: Tile.Position(row: row, column: currentColumn - 1),
                            isNew: false
                        )
                        board[row][currentColumn] = nil
                        currentColumn -= 1
                        moved = true
                    }
                    
                    // Check if we can merge with the tile to the left
                    if currentColumn > 0,
                       let leftTile = board[row][currentColumn - 1],
                       leftTile.value == tile.value,
                       !leftTile.isMerged {
                        
                        // Merge the tiles
                        let mergedValue = tile.value * 2
                        board[row][currentColumn - 1] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: row, column: currentColumn - 1),
                            isNew: false,
                            isMerged: true,
                            mergedFromIDs: (leftTile.id, tile.id)
                        )
                        board[row][currentColumn] = nil
                        
                        // Update score
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
                        // Check for win
                        if mergedValue >= Game2048Constants.winValue {
                            hasWon = true
                        }
                        
                        moved = true
                    }
                }
            }
        }
        
        return moved
    }
    
    private mutating func moveRight() -> Bool {
        var moved = false
        
        for row in 0..<Game2048Constants.boardSize {
            for column in (0..<Game2048Constants.boardSize - 1).reversed() {
                if let tile = board[row][column] {
                    var currentColumn = column
                    
                    // Move the tile right as far as possible
                    while currentColumn < Game2048Constants.boardSize - 1 && board[row][currentColumn + 1] == nil {
                        board[row][currentColumn + 1] = Tile(
                            value: tile.value,
                            position: Tile.Position(row: row, column: currentColumn + 1),
                            isNew: false
                        )
                        board[row][currentColumn] = nil
                        currentColumn += 1
                        moved = true
                    }
                    
                    // Check if we can merge with the tile to the right
                    if currentColumn < Game2048Constants.boardSize - 1,
                       let rightTile = board[row][currentColumn + 1],
                       rightTile.value == tile.value,
                       !rightTile.isMerged {
                        
                        // Merge the tiles
                        let mergedValue = tile.value * 2
                        board[row][currentColumn + 1] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: row, column: currentColumn + 1),
                            isNew: false,
                            isMerged: true,
                            mergedFromIDs: (rightTile.id, tile.id)
                        )
                        board[row][currentColumn] = nil
                        
                        // Update score
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
                        // Check for win
                        if mergedValue >= Game2048Constants.winValue {
                            hasWon = true
                        }
                        
                        moved = true
                    }
                }
            }
        }
        
        return moved
    }
    
    // Get all tiles as a flat array
    func getAllTiles() -> [Tile] {
        var tiles: [Tile] = []
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if let tile = board[row][column] {
                    tiles.append(tile)
                }
            }
        }
        return tiles
    }
    
    // Reset the game
    mutating func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: Game2048Constants.boardSize), count: Game2048Constants.boardSize)
        score = 0
        movesCount = 0
        hasWon = false
        isGameOver = false
        
        // Add initial tiles
        for _ in 0..<Game2048Constants.initialTileCount {
            addRandomTile()
        }
    }
}
