
import SwiftUI

enum MemoryGameConstants {
    static let gameDuration: TimeInterval = 90
    static let pairsCount = 12
    static let countdownDuration: Int = 2
    static let animationDuration: TimeInterval = 0.3
}

enum MemoryCardImage: Int, CaseIterable {
    case leaf = 1
    case mush
    case acorn
    case branch
    case butterfly
    case cloud
    case feather
    case flower
    case pinecone
    case rock
    case sun
    case waterDrop
    
    var imageName: ImageResource {
        switch self {
        case .leaf: return .leaf
        case .mush: return .mush
        case .acorn: return .acorn
        case .branch: return .branch
        case .butterfly: return .butterfly
        case .cloud: return .cloud
        case .feather: return .feather
        case .flower: return .flower
        case .pinecone: return .pinecone
        case .rock: return .rock
        case .sun: return .sun
        case .waterDrop: return .waterDrop
        }
    }
}

enum MemoryCardState {
    case faceDown
    case faceUp
    case matched
}

enum MemoryGameState: Equatable {
    case initial
    case countdown(Int)
    case playing
    case paused
    case finished(success: Bool)
}

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let imageIdentifier: Int
    var state: MemoryCardState = .faceDown
    let position: Position
    
    struct Position: Equatable {
        let row: Int
        let column: Int
    }
    
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Board Setup Configurations
struct MemoryBoardConfiguration {
    static let boardSize = 5 // 5x5 grid, with center cell empty
    static let totalCards = boardSize * boardSize - 1 // Excluding center cell
    
    // Generate shuffled pairs of cards
    static func generateCards() -> [MemoryCard] {
        var cards: [MemoryCard] = []
        let totalPairs = MemoryGameConstants.pairsCount
        
        // Create pairs of cards
        for i in 1...totalPairs {
            // Create two cards with the same image identifier
            for _ in 1...2 {
                // We'll add position assignment later when arranging on the grid
                cards.append(MemoryCard(imageIdentifier: i, position: .init(row: 0, column: 0)))
            }
        }
        
        // Shuffle the cards
        cards.shuffle()
        
        // Assign positions, skipping the center cell
        var index = 0
        for row in 0..<boardSize {
            for column in 0..<boardSize {
                // Skip the center cell
                if row == boardSize / 2 && column == boardSize / 2 {
                    continue
                }
                
                // Make sure we don't exceed array bounds
                guard index < cards.count else { break }
                
                // Update the position for the card
                cards[index] = MemoryCard(
                    imageIdentifier: cards[index].imageIdentifier,
                    position: .init(row: row, column: column)
                )
                index += 1
            }
        }
        
        return cards
    }
}
