
import SwiftUI

enum TicTacToeConstants {
    static let boardSize = 3
    static let animationDuration: TimeInterval = 0.2
}

enum Player: Equatable {
    case player1
    case player2
    
    var next: Player {
        self == .player1 ? .player2 : .player1
    }
    
    var imageName: ImageResource {
        switch self {
        case .player1: return .x
        case .player2: return ._0
        }
    }
    
    var displayName: String {
        switch self {
        case .player1: return "Player 1"
        case .player2: return "Player 2"
        }
    }
}

enum TicTacToeGameState: Equatable {
    case initial
    case playing
    case paused
    case finished(winner: Player?)
}

struct TicTacCell: Identifiable, Equatable {
    let id = UUID()
    let position: Position
    var player: Player?
    var isWinningCell: Bool = false
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    static func == (lhs: TicTacCell, rhs: TicTacCell) -> Bool {
        lhs.id == rhs.id &&
        lhs.position == rhs.position &&
        lhs.player == rhs.player &&
        lhs.isWinningCell == rhs.isWinningCell
    }
}

struct TicTacToe {
    var board: [[TicTacCell]]
    var currentPlayer: Player = .player1
    var isGameOver: Bool = false
    var winner: Player?
    var winningCombination: [TicTacCell.Position]?
    var moveCount: Int = 0
    
    init() {
        board = (0..<TicTacToeConstants.boardSize).map { row in
            (0..<TicTacToeConstants.boardSize).map { column in
                TicTacCell(position: TicTacCell.Position(row: row, column: column))
            }
        }
    }
    
    // MARK: - Game Logic
    
    mutating func makeMove(at position: TicTacCell.Position) -> Bool {
        guard isValidMove(at: position) else {
            return false
        }
        
        board[position.row][position.column].player = currentPlayer
        moveCount += 1
        
        if checkForWin() {
            isGameOver = true
            winner = currentPlayer
            markWinningCells()
        } else if moveCount == TicTacToeConstants.boardSize * TicTacToeConstants.boardSize {
            isGameOver = true
            winner = nil
        } else {
            currentPlayer = currentPlayer.next
        }
        
        return true
    }
    
    private func isValidMove(at position: TicTacCell.Position) -> Bool {
        guard !isGameOver else {
            return false
        }
        
        guard position.row >= 0 && position.row < TicTacToeConstants.boardSize &&
              position.column >= 0 && position.column < TicTacToeConstants.boardSize else {
            return false
        }
        
        return board[position.row][position.column].player == nil
    }
    
    mutating private func checkForWin() -> Bool {
        for row in 0..<TicTacToeConstants.boardSize {
            if let player = board[row][0].player,
               board[row][1].player == player &&
               board[row][2].player == player {
                winningCombination = [
                    TicTacCell.Position(row: row, column: 0),
                    TicTacCell.Position(row: row, column: 1),
                    TicTacCell.Position(row: row, column: 2)
                ]
                return true
            }
        }
        
        for column in 0..<TicTacToeConstants.boardSize {
            if let player = board[0][column].player,
               board[1][column].player == player &&
               board[2][column].player == player {
                winningCombination = [
                    TicTacCell.Position(row: 0, column: column),
                    TicTacCell.Position(row: 1, column: column),
                    TicTacCell.Position(row: 2, column: column)
                ]
                return true
            }
        }
        
        if let player = board[0][0].player,
           board[1][1].player == player &&
           board[2][2].player == player {
            winningCombination = [
                TicTacCell.Position(row: 0, column: 0),
                TicTacCell.Position(row: 1, column: 1),
                TicTacCell.Position(row: 2, column: 2)
            ]
            return true
        }
        
        if let player = board[2][0].player,
           board[1][1].player == player &&
           board[0][2].player == player {
            winningCombination = [
                TicTacCell.Position(row: 2, column: 0),
                TicTacCell.Position(row: 1, column: 1),
                TicTacCell.Position(row: 0, column: 2)
            ]
            return true
        }
        
        return false
    }
    
    private mutating func markWinningCells() {
        guard let winningPositions = winningCombination else {
            return
        }
        
        for position in winningPositions {
            board[position.row][position.column].isWinningCell = true
        }
    }
    
    func getAllCells() -> [TicTacCell] {
        var cells: [TicTacCell] = []
        for row in 0..<TicTacToeConstants.boardSize {
            for column in 0..<TicTacToeConstants.boardSize {
                cells.append(board[row][column])
            }
        }
        return cells
    }
    
    mutating func resetGame() {
        board = (0..<TicTacToeConstants.boardSize).map { row in
            (0..<TicTacToeConstants.boardSize).map { column in
                TicTacCell(position: TicTacCell.Position(row: row, column: column))
            }
        }
        currentPlayer = .player1
        isGameOver = false
        winner = nil
        winningCombination = nil
        moveCount = 0
    }
}
