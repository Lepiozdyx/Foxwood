//
//  AchievementsViewModel.swift
//  Foxwood
//
//  Created by Alex on 19.01.2025.
//

import SwiftUI

@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published private(set) var achievements: [Achievement] = []
    private let storageManager = StorageManager.shared
    
    init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        achievements = AchievementType.allCases.map { type in
            if let existingAchievement = storageManager.achievements.first(where: { $0.type == type }) {
                return existingAchievement
            } else {
                return Achievement.initial(type: type)
            }
        }
    }
    
    func achievementStyle(for achievement: Achievement) -> (opacity: Double, color: Color) {
        if achievement.isUnlocked {
            return (1.0, .white)
        } else {
            return (0.8, .black)
        }
    }
}
