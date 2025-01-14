//
//  StorageManager.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import Foundation

final class StorageManager: ObservableObject {
    static let shared = StorageManager()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let achievements = "achievements"
        static let musicEnabled = "musicEnabled"
        static let soundEnabled = "soundEnabled"
    }
    
    @Published var musicEnabled: Bool {
        didSet {
            defaults.set(musicEnabled, forKey: Keys.musicEnabled)
        }
    }
    
    @Published var soundEnabled: Bool {
        didSet {
            defaults.set(soundEnabled, forKey: Keys.soundEnabled)
        }
    }
    
    @Published private(set) var achievements: Set<Achievement> = []
    
    private init() {
        self.musicEnabled = defaults.bool(forKey: Keys.musicEnabled)
        self.soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        loadAchievements()
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        achievements.insert(achievement)
        saveAchievements()
    }
    
    private func loadAchievements() {
        if let data = defaults.data(forKey: Keys.achievements),
           let decoded = try? JSONDecoder().decode(Set<Achievement>.self, from: data) {
            achievements = decoded
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            defaults.set(encoded, forKey: Keys.achievements)
        }
    }
}
