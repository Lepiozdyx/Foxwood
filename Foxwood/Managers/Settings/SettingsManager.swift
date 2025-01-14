//
//  SettingsManager.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import Foundation

final class SettingsManager {
    
    private enum Keys: String {
        case isSoundOn
        case isMusicOn
        case isHapticsOn
    }
    
    static let shared = SettingsManager()
    
    var isSoundOn: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isSoundOn.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isSoundOn.rawValue) }
    }
    
    var isMusicOn: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isMusicOn.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isMusicOn.rawValue) }
    }
    
    var isHapticsOn: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isHapticsOn.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isHapticsOn.rawValue) }
    }
    
    private init() {
        if UserDefaults.standard.object(forKey: Keys.isSoundOn.rawValue) == nil {
            isSoundOn = true
        }
        if UserDefaults.standard.object(forKey: Keys.isMusicOn.rawValue) == nil {
            isMusicOn = true
        }
        if UserDefaults.standard.object(forKey: Keys.isHapticsOn.rawValue) == nil {
            isHapticsOn = true
        }
    }
}
