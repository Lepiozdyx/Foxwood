
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    enum OnboardingState: Int, CaseIterable {
        case first
        case second
        case third
        case fourth
        case completed
        
        var isLast: Bool {
            self == .fourth
        }
        
        var isCompleted: Bool {
            self == .completed
        }
        
        mutating func next() {
            guard let nextIndex = OnboardingState.allCases.firstIndex(of: self)?.advanced(by: 1),
                  nextIndex < OnboardingState.allCases.count else {
                self = .completed
                return
            }
            self = OnboardingState.allCases[nextIndex]
        }
    }
    
    @Published private(set) var currentState: OnboardingState = .first
    
    private let userDefaultsKey = "hasCompletedOnboarding"
    private let userDefaults: UserDefaults
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: userDefaultsKey) }
        set { userDefaults.set(newValue, forKey: userDefaultsKey) }
    }
    
    var buttonText: String {
        currentState.isLast ? "Start" : "Next"
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func moveToNextStep() {
        withAnimation(.easeInOut) {
            if currentState.isLast {
                completeOnboarding()
            } else {
                currentState.next()
            }
        }
    }
    
    func completeOnboarding() {
        currentState = .completed
        hasCompletedOnboarding = true
        HapticManager.shared.play(.success)
    }
    
    func resetOnboardingState() {
        hasCompletedOnboarding = false
        currentState = .first
    }
}
