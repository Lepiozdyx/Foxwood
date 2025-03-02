
import Foundation

enum AppState {
    case loading
    case initialWebView
    case onboarding
    case navigationRoot
}

@MainActor
final class ContentViewModel: ObservableObject {
    @Published private(set) var appState: AppState = .loading
    @Published var isOnboardingCompleted: Bool = false
    
    let networkManager: NetworkManager
    private let onboardingViewModel = OnboardingViewModel()
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
        self.isOnboardingCompleted = onboardingViewModel.hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        appState = .navigationRoot
    }
    
    func onAppear() {
        Task {
            if networkManager.checkedURL != nil {
                appState = .initialWebView
                return
            }
            
            do {
                if try await networkManager.checkInitialURL() {
                    appState = .initialWebView
                } else {
                    determineInitialState()
                }
            } catch {
                determineInitialState()
            }
        }
    }
    
    private func determineInitialState() {
        if isOnboardingCompleted {
            appState = .navigationRoot
        } else {
            appState = .onboarding
        }
    }
}
