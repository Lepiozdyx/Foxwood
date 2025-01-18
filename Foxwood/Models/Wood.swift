//
//  Wood.swift
//  Foxwood
//
//  Created by Alex on 18.01.2025.
//

import Foundation

enum WoodGameConstants {
    // Game Settings
    static let targetZoneWidth: CGFloat = 0.2 // 20% of total width
    static let indicatorSpeed: CGFloat = 0.5 // 1.5 - 2
    static let requiredSuccessStreak = 3
    static let maxMisses = 3
    static let countdownDuration: Int = 0 // 3
    
    // UI Settings
    static let scaleHeight: CGFloat = 40
    static let indicatorWidth: CGFloat = 20
    static let indicatorHeight: CGFloat = 60
    static let buttonSize: CGFloat = 100
    static let woodImageSize = CGSize(width: 230, height: 350)
}

enum WoodGameState: Equatable {
    case initial
    case countdown(Int)
    case playing
    case finished(success: Bool)
}

struct IndicatorPosition {
    var x: CGFloat // Position between 0 and 1
    var direction: Bool // true = right, false = left
    
    mutating func update() {
        if direction {
            x += WoodGameConstants.indicatorSpeed / 100
            if x >= 1 {
                x = 1
                direction = false
            }
        } else {
            x -= WoodGameConstants.indicatorSpeed / 100
            if x <= 0 {
                x = 0
                direction = true
            }
        }
    }
    
    static func isInTargetZone(_ position: CGFloat) -> Bool {
        let halfZoneWidth = WoodGameConstants.targetZoneWidth / 2
        let center = 0.5
        return position >= (center - halfZoneWidth) && position <= (center + halfZoneWidth)
    }
}

struct GameScore {
    var currentStreak: Int = 0
    var missCount: Int = 0
    var bestStreak: Int = 0
    
    mutating func handleHit(_ isSuccess: Bool) {
        if isSuccess {
            currentStreak += 1
            bestStreak = max(bestStreak, currentStreak)
        } else {
            currentStreak = 0
            missCount += 1
        }
    }
    
    var isGameOver: Bool {
        currentStreak >= WoodGameConstants.requiredSuccessStreak ||
        missCount >= WoodGameConstants.maxMisses
    }
    
    var hasWon: Bool {
        currentStreak >= WoodGameConstants.requiredSuccessStreak
    }
}
