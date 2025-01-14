//
//  HapticManager.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private let lightGenerator: UIImpactFeedbackGenerator
    private let mediumGenerator: UIImpactFeedbackGenerator
    private let heavyGenerator: UIImpactFeedbackGenerator
    private let selectionGenerator: UISelectionFeedbackGenerator
    private let notificationGenerator: UINotificationFeedbackGenerator
    
    private var isAvailable: Bool {
        UIDevice.current.hasHapticFeedback
    }
    
    private init() {
        lightGenerator = UIImpactFeedbackGenerator(style: .light)
        mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
        heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        selectionGenerator = UISelectionFeedbackGenerator()
        notificationGenerator = UINotificationFeedbackGenerator()
        
        if isAvailable {
            prepareGenerators()
        }
        
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(prepareGenerators),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    func play(_ type: HapticType, intensity: CGFloat = 1.0) {
        guard isAvailable && SettingsManager.shared.isHapticsOn else { return }
        
        switch type {
        case .light:
            lightGenerator.impactOccurred(intensity: intensity)
        case .medium:
            mediumGenerator.impactOccurred(intensity: intensity)
        case .heavy:
            heavyGenerator.impactOccurred(intensity: intensity)
        case .selection:
            selectionGenerator.selectionChanged()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Haptic Types
extension HapticManager {
    enum HapticType {
        case light
        case medium
        case heavy
        case selection
        case success
        case warning
        case error
    }
}

// MARK: - UIDevice Extension
private extension UIDevice {
    var hasHapticFeedback: Bool {
        if #available(iOS 13.0, *) {
            return !isFirstGenerationSE
        }
        return false
    }
    
    var isFirstGenerationSE: Bool {
        return model == "iPhone8,4"
    }
}
