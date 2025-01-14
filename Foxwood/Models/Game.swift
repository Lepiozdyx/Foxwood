//
//  Game.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import Foundation

// MARK: - Game Models
enum CellType: Equatable {
    case empty
    case web
    case wood
    case water
    case mushroom
    case berries
    
    var isResource: Bool {
        switch self {
        case .empty, .web:
            return false
        case .wood, .water, .mushroom, .berries:
            return true
        }
    }
}

struct Cell: Identifiable {
    let id = UUID()
    let position: Position
    var type: CellType
    var isRevealed: Bool = false
    
    struct Position: Equatable {
        let row: Int
        let column: Int
    }
}

enum ResourceType: CaseIterable {
    case wood
    case water
    case food
    
    var required: Int { 2 }
}

struct GameState {
    var resources: [ResourceType: Int] = [
        .wood: 0,
        .water: 0,
        .food: 0
    ]
    var movesLeft: Int = 10
    var isGameOver: Bool = false
    var hasWon: Bool = false
}

// MARK: - Board Setup Configurations
struct BoardConfiguration {
    static let boardSize = 5
    static let totalCells = boardSize * boardSize
    
    static let resourceDistribution: [CellType: Int] = [
        .wood: 4,
        .water: 4,
        .mushroom: 2,
        .berries: 2,
        .web: 5,
        .empty: 8
    ]
    
    // Predefined board layouts
    static let layouts: [[CellType]] = [
        // Layout 1
        [
            .wood,  .water, .empty, .web,   .mushroom,
            .web,   .empty, .wood,  .water, .empty,
            .empty, .web,   .empty, .wood,  .berries,
            .water, .empty, .web,   .empty, .wood,
            .berries, .web, .water, .empty, .mushroom
        ]
    ]
}
