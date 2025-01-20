
import Foundation
import SwiftUI

// MARK: - Constants
enum FoodGameConstants {
    static let gameDuration: TimeInterval = 30
    static let penaltyDuration: TimeInterval = 5
    static let requiredFoodCount = 10
    static let itemGenerationPeriod: TimeInterval = 0.65
    static let itemFallingDuration: TimeInterval = 2.2
    static let maxFallingItems = 45
    static let itemSize: CGFloat = 90
}

// MARK: - Models
enum FoodItemType {
    case mushroom
    case berries
    case poisonMushroom
    case bacteria
    case bacteria2
    
    var imageName: ImageResource {
        switch self {
        case .mushroom: return .mushroomButton
        case .berries: return .berriesButton
        case .poisonMushroom: return .poisonMushroomButton
        case .bacteria: return .bacteriaButton
        case .bacteria2: return .bacteria2Button
        }
    }
    
    var isEdible: Bool {
        switch self {
        case .mushroom, .berries: return true
        case .poisonMushroom, .bacteria, .bacteria2: return false
        }
    }
    
    static func randomType() -> FoodItemType {
        let types: [FoodItemType] = [
            .mushroom, .berries,
            .poisonMushroom, .bacteria, .bacteria2
        ]
        return types.randomElement() ?? .mushroom
    }
}

struct FoodItem: Identifiable {
    let id = UUID()
    let type: FoodItemType
    var position: CGPoint
    var isEnabled: Bool = true
}

enum FoodGameState: Equatable {
    case initial
    case countdown(Int)
    case playing
    case paused
    case finished(success: Bool)
}
