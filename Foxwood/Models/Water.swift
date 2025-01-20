
import Foundation
import SwiftUI

enum WaterGameConstants {
    // Game Settings
    static let gameDuration: TimeInterval = 30
    static let requiredDrops: Int = 10
    static let countdownDuration: Int = 3
    
    // Object Sizes
    static let snakeSize: CGFloat = 27
    static let dropSize: CGFloat = 27
    
    // Movement and Layout
    static let moveSpeed: CGFloat = 3.5
    static let updateInterval: TimeInterval = 1/60  
    static let borderPadding: CGFloat = 30
    static let statusBarSpacing: CGFloat = 10
    static let statusBarHeight: CGFloat = 50
}

enum WaterGameState: Equatable {
    case initial
    case countdown(Int)
    case playing
    case finished(success: Bool)
}

enum Direction {
    case up, down, left, right
    
    var movement: CGPoint {
        switch self {
        case .up: return CGPoint(x: 0, y: -WaterGameConstants.moveSpeed)
        case .down: return CGPoint(x: 0, y: WaterGameConstants.moveSpeed)
        case .left: return CGPoint(x: -WaterGameConstants.moveSpeed, y: 0)
        case .right: return CGPoint(x: WaterGameConstants.moveSpeed, y: 0)
        }
    }
}

struct SnakeSegment: Identifiable {
    let id = UUID()
    var position: CGPoint
}

struct WaterDrop: Identifiable {
    let id = UUID()
    var position: CGPoint
}
