
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
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    var tileImage: ImageResource {
        switch value {
        case 2: return ._2
        case 4: return ._4
        case 8: return ._8
        case 16: return ._16
        case 32: return ._32
        case 64: return ._64
        case 128: return ._128
        case 256: return ._256
        case 512: return ._512
        case 1024: return ._1024
        default: return ._2048
        }
    }
    
    mutating func resetMergeState() {
        isNew = false
        isMerged = false
    }
    
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
        board = Array(repeating: Array(repeating: nil, count: Game2048Constants.boardSize), count: Game2048Constants.boardSize)
        
        for _ in 0..<Game2048Constants.initialTileCount {
            addRandomTile()
        }
    }
    
    // MARK: - Game Logic
    
    mutating func addRandomTile() {
        var emptyCells: [Tile.Position] = []
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if board[row][column] == nil {
                    emptyCells.append(Tile.Position(row: row, column: column))
                }
            }
        }
        
        if emptyCells.isEmpty {
            return
        }
        
        let randomPosition = emptyCells.randomElement()!
        
        let value = Double.random(in: 0...1) < 0.9 ? 2 : 4
        let newTile = Tile(value: value, position: randomPosition, isNew: true)
        
        board[randomPosition.row][randomPosition.column] = newTile
    }
    
    mutating func checkGameOver() {
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if board[row][column] == nil {
                    return
                }
            }
        }
        
        for row in 0..<Game2048Constants.boardSize {
            for column in 0..<Game2048Constants.boardSize {
                if let tile = board[row][column] {
                    if column < Game2048Constants.boardSize - 1,
                       let rightTile = board[row][column + 1],
                       rightTile.value == tile.value {
                        return
                    }
                    
                    if row < Game2048Constants.boardSize - 1,
                       let downTile = board[row + 1][column],
                       downTile.value == tile.value {
                        return
                    }
                }
            }
        }
        
        isGameOver = true
    }
    
    mutating func move(_ direction: MoveDirection) -> Bool {
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
        
        if moved {
            addRandomTile()
            movesCount += 1
        }
        
        checkGameOver()
        
        return moved
    }
    
    private mutating func moveUp() -> Bool {
        var moved = false
        
        for column in 0..<Game2048Constants.boardSize {
            for row in 1..<Game2048Constants.boardSize {
                if let tile = board[row][column] {
                    var currentRow = row
                    
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
                    
                    if currentRow > 0,
                       let aboveTile = board[currentRow - 1][column],
                       aboveTile.value == tile.value,
                       !aboveTile.isMerged {
                        
                        let mergedValue = tile.value * 2
                        board[currentRow - 1][column] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: currentRow - 1, column: column),
                            isNew: false,
                            isMerged: true
                        )
                        board[currentRow][column] = nil
                        
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
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
                    
                    if currentRow < Game2048Constants.boardSize - 1,
                       let belowTile = board[currentRow + 1][column],
                       belowTile.value == tile.value,
                       !belowTile.isMerged {
                        
                        let mergedValue = tile.value * 2
                        board[currentRow + 1][column] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: currentRow + 1, column: column),
                            isNew: false,
                            isMerged: true
                        )
                        board[currentRow][column] = nil
                        
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
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
                    
                    if currentColumn > 0,
                       let leftTile = board[row][currentColumn - 1],
                       leftTile.value == tile.value,
                       !leftTile.isMerged {
                        
                        let mergedValue = tile.value * 2
                        board[row][currentColumn - 1] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: row, column: currentColumn - 1),
                            isNew: false,
                            isMerged: true
                        )
                        board[row][currentColumn] = nil
                        
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
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
                    
                    if currentColumn < Game2048Constants.boardSize - 1,
                       let rightTile = board[row][currentColumn + 1],
                       rightTile.value == tile.value,
                       !rightTile.isMerged {
                        
                        let mergedValue = tile.value * 2
                        board[row][currentColumn + 1] = Tile(
                            value: mergedValue,
                            position: Tile.Position(row: row, column: currentColumn + 1),
                            isNew: false,
                            isMerged: true
                        )
                        board[row][currentColumn] = nil
                        
                        score += mergedValue
                        bestScore = max(score, bestScore)
                        
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
