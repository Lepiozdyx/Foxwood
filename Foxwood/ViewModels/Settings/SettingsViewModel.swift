//
//  SettingsViewModel.swift
//  Foxwood
//
//  Created by Alex on 18.01.2025.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isMusicOn: Bool {
        didSet {
            SettingsManager.shared.isMusicOn = isMusicOn
            
            SoundManager.shared.updateMusicState()
            SoundManager.shared.playSound()
        }
    }
    
    @Published var isHapticsOn: Bool {
        didSet {
            SettingsManager.shared.isHapticsOn = isHapticsOn
            
            if isHapticsOn {
                HapticManager.shared.play(.selection)
            }
        }
    }
    
    init() {
        self.isMusicOn = SettingsManager.shared.isMusicOn
        self.isHapticsOn = SettingsManager.shared.isHapticsOn
    }
    
    func toggleMusic() {
        isMusicOn.toggle()
    }
    
    func toggleHaptics() {
        isHapticsOn.toggle()
    }
}
